const { db } = require("../config/firebase");
const notificationService = require("./notificationService");

/**
 * Get or create a chat thread.
 *
 * Two modes:
 *  - Listing thread  : listingId provided  → threadId = sorted(listingId, buyerId, sellerId)
 *  - Direct thread   : listingId omitted   → threadId = "direct_" + sorted(userId1, userId2)
 */
const getOrCreateThread = async (listingId, buyerId, sellerId) => {
  const isDirect = !listingId;
  const threadId = isDirect
    ? `direct_${[buyerId, sellerId].sort().join("_")}`
    : [listingId, buyerId, sellerId].sort().join("_");

  const ref = db.collection("chatThreads").doc(threadId);
  const doc = await ref.get();

  if (!doc.exists) {
    await ref.set({
      listingId: listingId || null,
      buyerId,
      sellerId,
      isDirect,
      lastMessage: "",
      lastMessageAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    });
  }
  return { id: threadId, ...(await ref.get()).data() };
};

/**
 * Send a message in a thread.
 */
const sendMessage = async (threadId, senderId, senderName, content) => {
  const threadRef = db.collection("chatThreads").doc(threadId);
  const threadDoc = await threadRef.get();
  if (!threadDoc.exists) {
    const error = new Error("Chat thread not found");
    error.statusCode = 404;
    throw error;
  }
  const thread = threadDoc.data();
  if (thread.buyerId !== senderId && thread.sellerId !== senderId) {
    const error = new Error("Not authorized to send messages in this thread");
    error.statusCode = 403;
    throw error;
  }

  const msgRef = db.collection("chatMessages").doc();
  const message = {
    threadId,
    senderId,
    senderName,
    content,
    read: false,
    createdAt: new Date().toISOString(),
  };
  await msgRef.set(message);

  await threadRef.update({
    lastMessage: content,
    lastMessageAt: new Date().toISOString(),
  });

  const recipientId =
    thread.buyerId === senderId ? thread.sellerId : thread.buyerId;
  await notificationService.notifyUser(recipientId, {
    title: `New message from ${senderName}`,
    body: content.length > 60 ? content.slice(0, 57) + "..." : content,
    data: { type: "chat_message", threadId },
  });

  return { id: msgRef.id, ...message };
};

/**
 * Get messages in a thread (chronological, last N).
 */
const getMessages = async (threadId, userId, limit = 50) => {
  const threadDoc = await db.collection("chatThreads").doc(threadId).get();
  if (!threadDoc.exists) {
    const error = new Error("Thread not found");
    error.statusCode = 404;
    throw error;
  }
  const thread = threadDoc.data();
  if (thread.buyerId !== userId && thread.sellerId !== userId) {
    const error = new Error("Not authorized");
    error.statusCode = 403;
    throw error;
  }

  const snapshot = await db
    .collection("chatMessages")
    .where("threadId", "==", threadId)
    .get();
  const messages = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return messages
    .sort((a, b) => (a.createdAt || "").localeCompare(b.createdAt || ""))
    .slice(-limit);
};

/**
 * Get all threads for a user, deduplicated by the other participant.
 * If a user has multiple threads with the same person (e.g. one per listing
 * plus a direct thread), only the most recent is returned so the chat list
 * shows one entry per person — not one per conversation thread.
 */
const getUserThreads = async (userId) => {
  const [buyerSnap, sellerSnap] = await Promise.all([
    db.collection("chatThreads").where("buyerId", "==", userId).get(),
    db.collection("chatThreads").where("sellerId", "==", userId).get(),
  ]);

  const allThreads = [
    ...buyerSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
    ...sellerSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
  ].sort((a, b) =>
    (b.lastMessageAt || "").localeCompare(a.lastMessageAt || "")
  );

  // Deduplicate: keep only the most-recent thread per unique other user.
  // Because the list is already sorted newest-first, the first occurrence
  // for each otherUserId is always the right one.
  const seen = new Set();
  const threads = allThreads.filter((t) => {
    const otherId = t.buyerId === userId ? t.sellerId : t.buyerId;
    if (seen.has(otherId)) return false;
    seen.add(otherId);
    return true;
  });

  // Batch-fetch the other participant's name for each unique thread
  const otherIds = threads.map((t) =>
    t.buyerId === userId ? t.sellerId : t.buyerId
  );

  const userDocs = await Promise.all(
    otherIds.map((id) => db.collection("users").doc(id).get())
  );
  const nameMap = {};
  userDocs.forEach((doc) => {
    if (doc.exists) nameMap[doc.id] = doc.data().name || "Farmer";
  });

  return threads.map((t) => {
    const otherId = t.buyerId === userId ? t.sellerId : t.buyerId;
    return {
      ...t,
      otherUserId: otherId,
      otherUserName: nameMap[otherId] || "Farmer",
    };
  });
};

/**
 * Mark all unread messages in a thread as read for the given user.
 */
const markAsRead = async (threadId, userId) => {
  const snapshot = await db
    .collection("chatMessages")
    .where("threadId", "==", threadId)
    .where("read", "==", false)
    .get();

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    if (doc.data().senderId !== userId) {
      batch.update(doc.ref, { read: true });
    }
  });
  await batch.commit();
};

/**
 * Edit a message. Only the original sender may edit their own messages.
 */
const editMessage = async (messageId, senderId, newContent) => {
  const ref = db.collection("chatMessages").doc(messageId);
  const doc = await ref.get();
  if (!doc.exists) {
    throw Object.assign(new Error("Message not found"), { statusCode: 404 });
  }
  if (doc.data().senderId !== senderId) {
    throw Object.assign(new Error("Not authorized to edit this message"), { statusCode: 403 });
  }
  const updated = {
    content: newContent.trim(),
    editedAt: new Date().toISOString(),
  };
  await ref.update(updated);
  // Reflect the edit in the thread's lastMessage preview if this was the latest
  const threadRef = db.collection("chatThreads").doc(doc.data().threadId);
  const threadDoc = await threadRef.get();
  if (threadDoc.exists && threadDoc.data().lastMessage === doc.data().content) {
    await threadRef.update({ lastMessage: updated.content });
  }
  return { id: messageId, ...doc.data(), ...updated };
};

/**
 * Delete a message. Only the original sender may delete their own messages.
 * Updates the thread's lastMessage to the previous message after deletion.
 */
const deleteMessage = async (messageId, senderId) => {
  const ref = db.collection("chatMessages").doc(messageId);
  const doc = await ref.get();
  if (!doc.exists) {
    throw Object.assign(new Error("Message not found"), { statusCode: 404 });
  }
  const data = doc.data();
  if (data.senderId !== senderId) {
    throw Object.assign(new Error("Not authorized to delete this message"), { statusCode: 403 });
  }
  await ref.delete();

  // Update the thread's lastMessage preview to the new most-recent message
  const remaining = await db
    .collection("chatMessages")
    .where("threadId", "==", data.threadId)
    .get();
  const threadRef = db.collection("chatThreads").doc(data.threadId);
  if (remaining.empty) {
    await threadRef.update({ lastMessage: "", lastMessageAt: new Date().toISOString() });
  } else {
    const sorted = remaining.docs
      .map((d) => ({ ...d.data() }))
      .sort((a, b) => (b.createdAt || "").localeCompare(a.createdAt || ""));
    await threadRef.update({
      lastMessage: sorted[0].content,
      lastMessageAt: sorted[0].createdAt,
    });
  }
};

module.exports = {
  getOrCreateThread,
  sendMessage,
  getMessages,
  getUserThreads,
  markAsRead,
  editMessage,
  deleteMessage,
};
