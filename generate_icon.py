"""
GrazeTrack Professional App Icon Generator - v2
Design: cow head with proper floppy ears, curved horns, grass strip
"""
from PIL import Image, ImageDraw
import math, os, random

SIZE = 1024

# Brand Colors
BG_MID      = (46, 125,  50)   # #2E7D32
BG_DARK     = (27,  94,  32)   # #1B5E20
BG_LIGHT    = (76, 175,  80)   # #4CAF50
ACCENT      = (129, 199, 132)  # #81C784
WHITE       = (255, 255, 255)
CREAM       = (240, 232, 215)  # snout / muzzle
EYE_DARK    = (  8,  28,  10)  # very dark green eyes
NOSTRIL_COL = ( 55,  25,  18)  # dark brown nostrils
EAR_INNER   = (178, 223, 180)  # light green inner ear
HORN_COL    = (205, 165,  90)  # warm tan horns
GRASS_DARK  = ( 27,  94,  32)
GRASS_MID   = ( 56, 142,  60)
GRASS_LIGHT = (102, 187, 106)


def grass_blade(draw, tip_x, tip_y, width, height, color, lean=0):
    base_y = tip_y + height
    base_x = tip_x + lean
    hw = width // 2
    control_x = tip_x + lean // 2
    control_y = tip_y + height // 2
    points = [
        (base_x - hw, base_y),
        (base_x + hw, base_y),
        (control_x + hw // 2, control_y),
        (tip_x, tip_y),
    ]
    draw.polygon(points, fill=color)


# ── Canvas ────────────────────────────────────────────────────────────────────
base = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(base)

CORNER_R = 210
draw.rounded_rectangle([0, 0, SIZE-1, SIZE-1], radius=CORNER_R, fill=BG_MID)

# Subtle center glow
for r, a in [(460, 20), (360, 14), (260, 9), (160, 5)]:
    cx, cy = SIZE//2, SIZE//2
    ov = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(*BG_LIGHT, a))
    base.alpha_composite(ov)
draw = ImageDraw.Draw(base)

# ── Cow geometry ──────────────────────────────────────────────────────────────
HEAD_CX, HEAD_CY = 512, 490
HEAD_RX, HEAD_RY = 205, 195

# ── Horns (above head, before ears so ears go on top) ────────────────────────
for thickness in range(12, 0, -2):
    hi = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hi)
    # left horn: starts top-left of head, curves up and right
    hd.arc(
        [HEAD_CX - 270, HEAD_CY - 280,
         HEAD_CX - 60,  HEAD_CY - 60],
        start=310, end=30, fill=(*HORN_COL, 255), width=thickness
    )
    # right horn: mirror
    hd.arc(
        [HEAD_CX + 60,  HEAD_CY - 280,
         HEAD_CX + 270, HEAD_CY - 60],
        start=150, end=230, fill=(*HORN_COL, 255), width=thickness
    )
    base.alpha_composite(hi)
draw = ImageDraw.Draw(base)

# ── Cow ears: wide flat ovals pointing outward (classic floppy cow ears) ─────
EAR_W, EAR_H = 115, 72   # wide & flat = cow ear, not round = pig ear
LEFT_EAR_CX,  LEFT_EAR_CY  = 320, 400
RIGHT_EAR_CX, RIGHT_EAR_CY = 704, 400

for (ecx, ecy) in [(LEFT_EAR_CX, LEFT_EAR_CY), (RIGHT_EAR_CX, RIGHT_EAR_CY)]:
    draw.ellipse([ecx-EAR_W, ecy-EAR_H, ecx+EAR_W, ecy+EAR_H], fill=WHITE)

# Inner ear (smaller, light green)
IEW, IEH = 72, 44
for (ecx, ecy) in [(LEFT_EAR_CX, LEFT_EAR_CY+5), (RIGHT_EAR_CX, RIGHT_EAR_CY+5)]:
    draw.ellipse([ecx-IEW, ecy-IEH, ecx+IEW, ecy+IEH], fill=EAR_INNER)

# ── Main head ─────────────────────────────────────────────────────────────────
draw.ellipse(
    [HEAD_CX-HEAD_RX, HEAD_CY-HEAD_RY,
     HEAD_CX+HEAD_RX, HEAD_CY+HEAD_RY],
    fill=WHITE
)

# ── Brown patch on forehead (distinctive cow marking) ────────────────────────
patch = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
pd   = ImageDraw.Draw(patch)
pd.ellipse(
    [HEAD_CX-75, HEAD_CY-170,
     HEAD_CX+75, HEAD_CY-30],
    fill=(185, 120, 60, 90)   # warm brown, semi-transparent
)
base.alpha_composite(patch)
draw = ImageDraw.Draw(base)

# ── Eyes — large, spaced wide (cow eyes are on the sides of the head) ─────────
EYE_RX, EYE_RY = 36, 30      # slightly oval
PUPIL_R  = 18
SHINE_R  = 8
LEFT_EYE_X,  LEFT_EYE_Y  = HEAD_CX - 95, HEAD_CY - 20
RIGHT_EYE_X, RIGHT_EYE_Y = HEAD_CX + 95, HEAD_CY - 20

for (ex, ey) in [(LEFT_EYE_X, LEFT_EYE_Y), (RIGHT_EYE_X, RIGHT_EYE_Y)]:
    draw.ellipse([ex-EYE_RX, ey-EYE_RY, ex+EYE_RX, ey+EYE_RY], fill=EYE_DARK)
    draw.ellipse([ex-PUPIL_R, ey-PUPIL_R, ex+PUPIL_R, ey+PUPIL_R], fill=(4, 4, 4))
    draw.ellipse([ex-SHINE_R+10, ey-SHINE_R-8,
                  ex+SHINE_R-4,  ey+SHINE_R-16], fill=WHITE)

# ── Snout — smaller, lower — cow-proportioned ─────────────────────────────────
SNOUT_CX, SNOUT_CY = HEAD_CX, HEAD_CY + 100
SNOUT_RX, SNOUT_RY = 88, 60
draw.ellipse(
    [SNOUT_CX-SNOUT_RX, SNOUT_CY-SNOUT_RY,
     SNOUT_CX+SNOUT_RX, SNOUT_CY+SNOUT_RY],
    fill=CREAM
)

# Nostrils
NR = 18
draw.ellipse([SNOUT_CX-40-NR, SNOUT_CY-NR, SNOUT_CX-40+NR, SNOUT_CY+NR], fill=NOSTRIL_COL)
draw.ellipse([SNOUT_CX+40-NR, SNOUT_CY-NR, SNOUT_CX+40+NR, SNOUT_CY+NR], fill=NOSTRIL_COL)

# ── Grass strip at the bottom ─────────────────────────────────────────────────
GRASS_BASE_Y = SIZE - 190

# Dark ground fill
draw.rectangle([0, GRASS_BASE_Y + 60, SIZE, SIZE], fill=BG_DARK)

random.seed(99)
# Back layer blades
for _ in range(60):
    bx   = random.randint(10, SIZE-10)
    bh   = random.randint(70, 130)
    bw   = random.randint(10, 18)
    lean = random.randint(-26, 26)
    col  = random.choice([GRASS_DARK, GRASS_MID, BG_MID, BG_LIGHT])
    grass_blade(draw, bx, GRASS_BASE_Y - bh + 60, bw, bh, col, lean)

# Front layer blades (slightly taller/bigger)
for _ in range(28):
    bx   = random.randint(10, SIZE-10)
    bh   = random.randint(80, 120)
    bw   = random.randint(10, 15)
    lean = random.randint(-20, 20)
    col  = random.choice([GRASS_MID, GRASS_LIGHT, BG_LIGHT])
    grass_blade(draw, bx, GRASS_BASE_Y - bh + 80, bw, bh, col, lean)

# ── Flatten & save ─────────────────────────────────────────────────────────────
OUT_DIR = os.path.join(os.path.dirname(__file__),
                       "frontend", "grazetrack_app", "assets", "icons")
os.makedirs(OUT_DIR, exist_ok=True)

final = Image.new('RGB', (SIZE, SIZE), (46, 125, 50))
final.paste(base, mask=base.split()[3])
OUT_PATH = os.path.join(OUT_DIR, "app_icon.png")
FG_PATH  = os.path.join(OUT_DIR, "app_icon_foreground.png")
final.save(OUT_PATH, 'PNG', optimize=True)
final.save(FG_PATH,  'PNG')
print(f"Icon saved: {OUT_PATH}")
print(f"Foreground: {FG_PATH}")
