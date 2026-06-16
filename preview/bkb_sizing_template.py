import numpy as np, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle, Circle
from matplotlib.backends.backend_pdf import PdfPages

# ---- params (mirror backkb_v1_keywell.scad current values) ----
phone_len = 162.3 + 2*2.5      # 167.3 cased
phone_wid = 79.0  + 2*2.5      # 84.0
corner_r  = 9.0
hand_x, hand_y = 55.0, 0.0
pitch_y = 4.0                  # deg, about Y
col_y   = [36,18,0,-18,-36]
col_xs  = [6,2,0,3,10]
col_z   = [-2,-1,0,-1,-3]
curv_top, curv_bot, row_curv = 10.0, 80.0, 4.0
row_spacing = 17.0
rr_top = row_spacing/np.radians(curv_top)
rr_bot = 8.0
keycap = 18.0
choc   = 14.0
fingers = ["pinky","ring","mid","idx-o","idx-i"]
rows = ["top","home","bot"]

def key_center(col,row):
    y0=col_y[col]; xs=col_xs[col]; z0=col_z[col]
    rr = row-1
    th = 0.0 if rr==0 else (-curv_top*rr if rr<0 else -curv_bot*rr)
    arc = rr_top if rr<=0 else rr_bot
    th=np.radians(th); phi=np.radians(row_curv*(col-2))
    # pivot trick
    x = -arc*np.sin(th)
    z = z0 + arc*(1-np.cos(th))
    # splay about Z
    X = xs + x*np.cos(phi); Y = y0 + x*np.sin(phi)
    # hand pitch about Y (affects X,Z): X' = X cos b + z sin b
    b=np.radians(pitch_y)
    Xw = hand_x + X*np.cos(b) + z*np.sin(b)
    Yw = hand_y + Y
    return Xw, Yw

# thumb cage center (top edge) + palm marker
thumb_c = (60.0, 52.5)
palm_c  = (86.0, 8.0)

# drawing extents (mm)
xlo,xhi = -98, 98
ylo,yhi = -66, 64
W = xhi-xlo; H = yhi-ylo

fig = plt.figure(figsize=(W/25.4, H/25.4))
ax = fig.add_axes([0,0,1,1])
ax.set_xlim(xlo,xhi); ax.set_ylim(ylo,yhi); ax.set_aspect("equal")
ax.axis("off")

# phone outline (cased)
ax.add_patch(FancyBboxPatch((-phone_len/2,-phone_wid/2), phone_len, phone_wid,
    boxstyle=f"round,pad=0,rounding_size={corner_r}",
    fill=False, edgecolor="#222", linewidth=1.5))
ax.text(0,0,"S24U + Otterbox\n167.3 x 84.0 mm\n(cased back, landscape)",
    ha="center",va="center",color="#999",fontsize=7)

# finger keys, both hands
def draw_keys(mirror):
    s = -1 if mirror else 1
    for col in range(5):
        cxs,cys=[],[]
        for row in range(3):
            X,Y=key_center(col,row); X*=s
            cxs.append(X);cys.append(Y)
            # keycap (touch) square + choc cutout
            ax.add_patch(Rectangle((X-keycap/2,Y-keycap/2),keycap,keycap,
                fill=False,edgecolor="#4477cc",linewidth=0.5))
            ax.add_patch(Rectangle((X-choc/2,Y-choc/2),choc,choc,
                fill=False,edgecolor="#aaccee",linewidth=0.4))
            ax.plot(X,Y,"+",color="#4477cc",ms=4,mew=0.6)
        ax.plot(cxs,cys,color="#4477cc",lw=0.4,alpha=0.5)
        if not mirror:
            ax.text(cxs[0],cys[0]+keycap/2+1.5,fingers[col],ha="center",fontsize=5,color="#4477cc")

draw_keys(False); draw_keys(True)

# thumb cage footprint (both hands)
for s in (1,-1):
    tx,ty=thumb_c[0]*s,thumb_c[1]
    ax.add_patch(Rectangle((tx-7.5,ty-7.5),15,15,fill=False,edgecolor="#cc7722",linewidth=0.8))
    ax.text(tx,ty,"thumb\ncage",ha="center",va="center",fontsize=5,color="#cc7722")
# palm activation (both hands, on outboard end)
for s in (1,-1):
    px,py=palm_c[0]*s,palm_c[1]
    ax.add_patch(Circle((px,py),5,fill=False,edgecolor="#33aa55",linewidth=0.8))
    ax.text(px,py-8,"palm\nactivate",ha="center",va="center",fontsize=4.5,color="#33aa55")

# 100mm scale bar (print-verify) at bottom
ax.plot([-50,50],[-62,-62],color="#cc0000",lw=1.2)
for x in (-50,0,50):
    ax.plot([x,x],[-63,-61],color="#cc0000",lw=1.2)
ax.text(0,-60,"100 mm — measure to verify print scale (print at 100% / Actual Size, NOT Fit to Page)",
    ha="center",fontsize=6,color="#cc0000")

# title + legend
ax.text(0,61,"backkb (bkb) v1 — 1:1 sizing template  ·  right + left hands  ·  plan view (key tops)",
    ha="center",fontsize=7,color="#222")
ax.text(-95,55,"blue = keycap 18mm / choc 14mm\norange = thumb cage\ngreen = palm activation",
    ha="left",va="top",fontsize=5,color="#555")

with PdfPages("/tmp/bkb_sizing_template.pdf") as pdf:
    pdf.savefig(fig)
plt.close(fig)
print("PDF written:", W, "x", H, "mm drawing")
