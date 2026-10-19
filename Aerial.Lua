local Players, RS, TS, HS, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("TweenService"), game:GetService("HttpService"), game:GetService("UserInputService")
local AES, MP = game:GetService("AvatarEditorService"), game:GetService("MarketplaceService")
local lp, T = Players.LocalPlayer, Enum.AvatarAssetType
local W, B = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local env = (getgenv and getgenv()) or _G
if env.ProtonaCleanup then pcall(env.ProtonaCleanup) end
if env.AerialCleanup then pcall(env.AerialCleanup) end
env.PMem = env.PMem or {}
local U = {eq = {}, tr = {}, ch = {}, df = {}, bc = {}, wl = {}, rf = {}, pg = {}, cn = {}, m = "items",
  sub = {items = "Hats", clothes = "Shirt", chars = "bundles", emotes = "browse", anims = "Run", edit = "resize", settings = "language"}}

-- FILES + SETTINGS (old Protona saves still load) -------------------
local canFS = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
function U.rd(n)
  if not canFS then return env.PMem[n] end
  for _, dir in ipairs({"Aerial", "Protona"}) do
    local ok, d = pcall(function() local p = dir .. "/" .. n if isfile(p) then return readfile(p) end end)
    if ok and d then local o, t = pcall(HS.JSONDecode, HS, d) if o then return t end end
  end
end
function U.wr(n, t)
  if not canFS then env.PMem[n] = t return false end
  pcall(function() if makefolder and not (isfolder and isfolder("Aerial")) then makefolder("Aerial") end end)
  local ok = pcall(function() writefile("Aerial/" .. n, HS:JSONEncode(t)) end)
  if not ok then env.PMem[n] = t end
  return ok
end
local DEF = {lang = "en", col = {255, 255, 255}, font = "Gotham", round = 1, bgm = "Aurora", click = "Pop", scale = 1, ut = "Modern", auto = "", spin = true, rig = "Auto", off = true, grey = true}
local S = {}
for k, v in pairs(DEF) do S[k] = v end
local sv = U.rd("settings.json")
if type(sv) == "table" then for k, v in pairs(sv) do if DEF[k] ~= nil then S[k] = v end end end
function U.save() U.wr("settings.json", S) end
local cfgs = U.rd("configs.json")
if type(cfgs) ~= "table" then cfgs = {} end

-- TRANSLATIONS ------------------------------------------------------
local LG = {"en", "es", "fr", "de", "pt"}
local TR = {}
for _, l in ipairs(LG) do TR[l] = {} end
for k, v in ([[
items=Items|Objetos|Objets|Items|Itens
clothes=Clothes|Ropa|Vêtements|Kleidung|Roupas
chars=Characters|Personajes|Persos|Figuren|Personagens
emotes=Emotes|Emotes|Emotes|Emotes|Emotes
anims=Anims|Anims|Anims|Anims|Anims
edit=Edit|Editar|Éditer|Ändern|Editar
configs=Configs|Configs|Configs|Configs|Configs
settings=Settings|Ajustes|Réglages|Optionen|Ajustes
bundles=Bundles|Paquetes|Packs|Bundles|Pacotes
official=Official|Oficial|Officiel|Offiziell|Oficial
browse=Browse|Explorar|Parcourir|Suchen|Explorar
wheel=Wheel|Rueda|Roue|Rad|Roda
resize=Resize|Tamaño|Taille|Größe|Tamanho
color=Color|Color|Couleur|Farbe|Cor
language=Language|Idioma|Langue|Sprache|Idioma
colors=Colors|Colores|Couleurs|Farben|Cores
font=Font|Fuente|Police|Schrift|Fonte
style=Style|Estilo|Style|Stil|Estilo
effects=Effects|Efectos|Effets|Effekte|Efeitos
equipped=Equipped|Equipado|Équipé|Angelegt|Equipado
clear=Clear|Borrar|Vider|Leeren|Limpar
undo=Undo|Deshacer|Annuler|Zurück|Desfazer
spin=Spin|Girar|Tourner|Drehen|Girar
grey=Grey|Gris|Gris|Grau|Cinza
try=Try|Probar|Essayer|Anprobe|Provar
wear=Wear|Poner|Porter|Anziehen|Vestir
publish=Publish|Publicar|Publier|Senden|Publicar
search=Search|Buscar|Chercher|Suchen|Buscar
keep=Keep|Dejar|Garder|Behalten|Manter
takeoff=Take off|Quitar|Retirer|Ablegen|Tirar
more=More|Más|Plus|Mehr|Mais
default=Default|Original|Défaut|Standard|Padrão
save=Save|Guardar|Sauver|Speichern|Salvar
load=Load|Cargar|Charger|Laden|Carregar
delete=Delete|Borrar|Suppr.|Löschen|Apagar
auto=Auto|Auto|Auto|Auto|Auto
cfgname=config name...|nombre...|nom...|Name...|nome...
cfgempty=No saved configs yet|Aún no hay configs|Aucune config|Keine Configs|Nenhuma config
apply=Apply|Aplicar|Appliquer|Anwenden|Aplicar
uitype=UI type|Tipo de UI|Type d'UI|UI-Typ|Tipo de UI
corners=Corners|Esquinas|Coins|Ecken|Cantos
size=Size|Tamaño|Taille|Größe|Tamanho
bgs=Background|Fondo|Fond|Hintergrund|Fundo
click=Click effect|Efecto clic|Effet clic|Klick-Effekt|Efeito clique
theme=Theme color|Color del tema|Couleur du thème|Themenfarbe|Cor do tema
solid=Solid|Sólido|Uni|Einfarbig|Sólido
orig=Original|Original|Original|Original|Original
]]):gmatch("(%w+)=([^\n]+)") do
  local i = 0
  for s in (v .. "|"):gmatch("(.-)|") do i += 1 if LG[i] then TR[LG[i]][k] = s end end
end
local function L(k) return (TR[S.lang] and TR[S.lang][k]) or TR.en[k] or k end

-- THEME (one color tints the whole menu) ----------------------------
local th = {}
local function c3(t) return Color3.fromRGB(t[1], t[2], t[3]) end
local function fnt(n) local ok, f = pcall(function() return Enum.Font[n] end) return ok and f or Enum.Font.Gotham end
local function theme()
  local m = c3(S.col)
  th.m, th.bg, th.pn, th.tx = m, m:Lerp(B, 0.93), m:Lerp(B, 0.82), m:Lerp(W, 0.8)
  th.at = (0.299 * m.R + 0.587 * m.G + 0.114 * m.B) > 0.55 and B or W
  th.f = fnt(S.font)
end
theme()
local function hexrgb(s)
  s = (tostring(s):gsub("[#%s]", ""))
  if #s ~= 6 then return nil end
  local r, g, b = tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16)
  if r and g and b then return {r, g, b} end
end

-- DATA --------------------------------------------------------------
local CAT = {
  Hats = {T.Hat, "HatAccessory"}, Hair = {T.HairAccessory, "HairAccessory"}, Face = {T.FaceAccessory, "FaceAccessory"},
  Shoulder = {T.ShoulderAccessory, "ShouldersAccessory"}, Back = {T.BackAccessory, "BackAccessory"},
  Front = {T.FrontAccessory, "FrontAccessory"}, Neck = {T.NeckAccessory, "NeckAccessory"}, Waist = {T.WaistAccessory, "WaistAccessory"},
  Shirt = {T.Shirt, nil, "Shirt"}, Pants = {T.Pants, nil, "Pants"}, TShirt = {T.TShirt, nil, "ShirtGraphic"},
}
local PG = {
  items = {subs = {"Hats", "Hair", "Face", "Shoulder", "Back", "Front", "Neck", "Waist"}, k = "cat"},
  clothes = {subs = {"Shirt", "Pants", "TShirt"}, k = "cat"},
  chars = {subs = {"bundles", "T", "H", "RA", "LA", "RL", "LL", "official"}, k = "char"},
  emotes = {subs = {"browse", "wheel"}, k = "emo"},
  anims = {subs = {"Run", "Jump", "Fall", "Walk", "Idle"}, k = "anim"},
  edit = {subs = {"resize", "color"}, k = "edit"},
  configs = {k = "cfg"},
  settings = {subs = {"language", "colors", "font", "style", "effects"}, k = "set"},
}
local MAINS = {"items", "clothes", "chars", "emotes", "anims", "edit", "configs", "settings"}
local PART = {T = "Torso", RL = "RightLeg", LL = "LeftLeg", RA = "RightArm", LA = "LeftArm", H = "Head"}
local TAG = {} for k, v in pairs(PART) do TAG[v] = k end
local ATID = {Head = 17, Torso = 27, RightArm = 28, LeftArm = 29, LeftLeg = 30, RightLeg = 31}
local BP = {Head = Enum.BodyPart.Head, Torso = Enum.BodyPart.Torso, RightArm = Enum.BodyPart.RightArm, LeftArm = Enum.BodyPart.LeftArm, RightLeg = Enum.BodyPart.RightLeg, LeftLeg = Enum.BodyPart.LeftLeg}
local G15 = {RightLeg = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}, LeftLeg = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
  RightArm = {"RightUpperArm", "RightLowerArm", "RightHand"}, LeftArm = {"LeftUpperArm", "LeftLowerArm", "LeftHand"},
  Torso = {"UpperTorso", "LowerTorso"}, Head = {"Head"}}
local WHOLE = {RightLeg = Vector3.new(1, 2, 1), LeftLeg = Vector3.new(1, 2, 1), RightArm = Vector3.new(1, 2, 1), LeftArm = Vector3.new(1, 2, 1), Torso = Vector3.new(2, 2, 1), Head = Vector3.new(1, 1, 1)}
local HEADLESS = 134082579
local PINS = {RL = {"Korblox", "RightLeg", 139607718}, H = {"Headless", "Head", HEADLESS}}
local AN = {Run = {"run", "RunAnim"}, Walk = {"walk", "WalkAnim"}, Jump = {"jump", "JumpAnim"}, Fall = {"fall", "FallAnim"}, Idle = {"idle", "Animation1", "Animation2"}}
local PK = {}
for l in ([[
Oldschool 5319828216 5319847204 5319844329 5319841935 5319839762
Ninja 656117400 656121766 656118852 656117878 656115606
Zombie 616158929 616168032 616163682 616161997 616157476
Astronaut 891621366 891667138 891636393 891627522 891617961
Cartoony 742637544 742640026 742638842 742637942 742637151
Levitation 616006778 616013216 616010382 616008936 616005863
Robot 616088211 616095330 616091570 616090535 616087089
Stylish 616136790 616146177 616140816 616139451 616134815
Superhero 616111295 616122287 616117076 616115533 616108001
Vampire 1083445855 1083473930 1083462077 1083455352 1083443587
Werewolf 1083195517 1083178339 1083216690 1083218792 1083189019
Toy 782841498 782843345 782842708 782847020 782846423
Mage 707742142 707897309 707861613 707853694 707829716
Pirate 750781874 750785693 750783738 750782230 750780242
Knight 657595757 657552124 657564596 658409194 657600338
Elder 845397899 845403856 845386501 845398858 845396048
Bubbly 910004836 910034870 910025107 910016857 910001910
Sneaky 1132473842 1132510133 1132494274 1132489853 1132469004
Confident 1069977950 1070017263 1070001516 1069984524 1069973677
Princess 941003647 941028902 941015281 941008832 941000007
Cowboy 1014390418 1014421541 1014401683 1014394726 1014384571
Popstar 1212900985 1212980338 1212980348 1212954642 1212900995
]]):gmatch("[^\n]+") do
  local n, a, b, c, d, e = l:match("(%S+) (%d+) (%d+) (%d+) (%d+) (%d+)")
  PK[#PK + 1] = {n = n, Idle = tonumber(a), Walk = tonumber(b), Run = tonumber(c), Jump = tonumber(d), Fall = tonumber(e)}
end
local PAL = "FFFFFF B3B3B3 808080 4D4D4D 262626 000000 FF3B30 FF6B6B C0392B 7B1113 FF9500 FFB347 E67E22 FFD60A FFF176 34C759 7CFC00 145A32 98FF98 00E5D0 26C6DA 0A84FF 5AC8FA 1565C0 5E5CE6 B388FF 9C27B0 FF2D92 FF80AB 8E2A5B 8D6E63 FFDAB9"
local FONTS = {}
for _, n in ipairs({"Gotham", "Ubuntu", "Arcade", "SciFi", "Fantasy", "Cartoon", "Code", "Bangers", "Michroma", "Oswald", "Nunito", "Jura", "PermanentMarker", "RobotoMono"}) do
  if pcall(function() return Enum.Font[n] end) then FONTS[#FONTS + 1] = n end
end
local UTN = {"Modern", "Neon", "Retro", "Soft", "Ice", "Minimal"}
local UT = {Modern = {1, "Gotham", {255, 255, 255}, "Aurora"}, Neon = {2, "Michroma", {0, 255, 200}, "Fireflies"},
  Retro = {0, "Code", {0, 255, 90}, "Rain"}, Soft = {2, "Nunito", {255, 128, 171}, "Bubbles"},
  Ice = {1, "Jura", {90, 200, 250}, "Snow"}, Minimal = {1, "Gotham", {200, 200, 200}, "Plain"}}
local MODES = {Aurora = {n = 40, s = {1, 3}, tw = 1}, Stars = {n = 44, s = {1, 3}, tw = 1}, Snow = {n = 36, s = {2, 4}, vx = {-.02, .02}, vy = {.04, .1}, rd = 1, sw = 1},
  Rain = {n = 40, s = {1, 1}, h = 10, vy = {.7, 1.2}}, Bubbles = {n = 20, s = {6, 14}, vy = {-.12, -.04}, rd = 1, sw = 1},
  Fireflies = {n = 24, s = {3, 5}, vx = {-.03, .03}, vy = {-.03, .03}, tw = 1, rd = 1}, Plain = {n = 0}}
local MODEN = {"Aurora", "Stars", "Snow", "Rain", "Bubbles", "Fireflies", "Plain"}

-- GUI ROOT + REGISTRIES ---------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AerialGui" gui.ResetOnSpawn = false
if not pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end) then gui.Parent = lp:WaitForChild("PlayerGui") end
local sk, lc = {}, {}
local function skin(o, fn)
  sk[#sk + 1] = {o, fn}
  if #sk % 300 == 0 then for i = #sk, 1, -1 do if not sk[i][1]:IsDescendantOf(gui) then table.remove(sk, i) end end end
  pcall(fn)
end
function U.retheme() for i = #sk, 1, -1 do local e = sk[i] if e[1]:IsDescendantOf(gui) then pcall(e[2]) else table.remove(sk, i) end end end
function U.lang() for i = #lc, 1, -1 do local e = lc[i] if e[1]:IsDescendantOf(gui) then e[1].Text = L(e[2]) else table.remove(lc, i) end end end

local function paint(b)
  if b:GetAttribute("fx") then b.Font = th.f b.TextColor3 = W return end
  local on = b:GetAttribute("on")
  b.BackgroundColor3 = on and th.m or th.pn
  b.BackgroundTransparency = on and 0.05 or 0.35
  b.TextColor3 = on and th.at or th.tx
  local f = b:GetAttribute("fn") b.Font = f and fnt(f) or th.f
end
local function setOn(b, v) b:SetAttribute("on", v) paint(b) end
local function crn(o, r) local c = Instance.new("UICorner") c.Parent = o skin(c, function() c.CornerRadius = UDim.new(0, r * S.round) end) end
local function stk(o, t)
  local s = Instance.new("UIStroke") s.Transparency = t or 0.7 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Parent = o
  skin(s, function() s.Color = th.m end)
end
local function lbl(p, t, sz, pos, size, al, raw)
  local l = Instance.new("TextLabel") l.BackgroundTransparency = 1 l.TextSize = sz l.Position = pos l.Size = size l.ZIndex = 6
  l.TextXAlignment = al or Enum.TextXAlignment.Center l.Parent = p
  skin(l, function() l.TextColor3 = th.tx l.Font = th.f end)
  if not raw and TR.en[t] then l.Text = L(t) lc[#lc + 1] = {l, t} else l.Text = t end
  return l
end
local function pop(b)
  local m = S.click
  if m == "Off" then return end
  if m ~= "Ripple" then
    local s = b:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", b)
    s.Scale = 0.86
    TS:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
  end
  if m ~= "Pop" and b:IsA("TextButton") then
    b.ClipsDescendants = true
    local r = Instance.new("Frame") r.AnchorPoint = Vector2.new(.5, .5) r.Position = UDim2.fromScale(.5, .5)
    r.Size = UDim2.fromOffset(0, 0) r.BackgroundColor3 = W r.BackgroundTransparency = 0.6 r.BorderSizePixel = 0 r.ZIndex = 8 r.Parent = b
    Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)
    TS:Create(r, TweenInfo.new(0.4), {Size = UDim2.fromOffset(130, 130), BackgroundTransparency = 1}):Play()
    task.delay(0.45, function() r:Destroy() end)
  end
end
local function btn(p, t, pos, sz, raw)
  local b = Instance.new("TextButton") b.AutoButtonColor = false b.TextSize = 11 b.BorderSizePixel = 0
  b.Position = pos b.Size = sz b.ZIndex = 6 b:SetAttribute("on", false) b.TextScaled = true b.Parent = p
  local c = Instance.new("UITextSizeConstraint") c.MaxTextSize = 11 c.MinTextSize = 7 c.Parent = b
  crn(b, 8) stk(b)
  skin(b, function() paint(b) end)
  if not raw and TR.en[t] then b.Text = L(t) lc[#lc + 1] = {b, t} else b.Text = t end
  b.MouseButton1Down:Connect(function() pop(b) end)
  return b
end
local function tbx(p, pos, sz)
  local t = Instance.new("TextBox") t.Text = "" t.ClearTextOnFocus = false t.TextSize = 12 t.BorderSizePixel = 0
  t.Position = pos t.Size = sz t.ZIndex = 6 t.Parent = p
  crn(t, 8) stk(t)
  skin(t, function() t.BackgroundColor3 = th.pn t.BackgroundTransparency = 0.35 t.TextColor3 = th.tx t.PlaceholderColor3 = th.tx:Lerp(th.pn, 0.45) t.Font = th.f end)
  return t
end
local function pnl(o, tr) skin(o, function() o.BackgroundColor3 = th.pn o.BackgroundTransparency = tr end) end
local function hum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function thumb(id) return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150" end

-- WINDOW + BACKGROUNDS ----------------------------------------------
local menu = Instance.new("Frame")
menu.AnchorPoint = Vector2.new(.5, .5) menu.Position = UDim2.fromScale(.5, .5) menu.Size = UDim2.fromOffset(520, 322)
menu.BorderSizePixel = 0 menu.ClipsDescendants = true menu.Active = true menu.Draggable = true menu.Parent = gui
crn(menu, 16)
skin(menu, function() menu.BackgroundColor3 = th.bg end)
local ms = Instance.new("UIStroke") ms.Thickness = 2 ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border ms.Parent = menu
local mg = Instance.new("UIGradient") mg.Parent = ms
skin(ms, function() ms.Color = W mg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, th.m), ColorSequenceKeypoint.new(.5, th.m:Lerp(W, .55)), ColorSequenceKeypoint.new(1, th.m)}) end)
local us = Instance.new("UIScale") us.Parent = menu
local cam = workspace.CurrentCamera
function U.fit() local v = cam.ViewportSize us.Scale = math.clamp(math.min((v.Y - 16) / 322, (v.X - 16) / 520), 0.4, 1.15) * S.scale end
U.fit() U.cn[#U.cn + 1] = cam:GetPropertyChangedSignal("ViewportSize"):Connect(U.fit)

local LAY, PT = {}, {}
for i, c in ipairs({{15, .35, 0, .25, .75}, {-20, .25, 2, .35, .8}}) do
  local f = Instance.new("Frame") f.Size = UDim2.fromScale(1, 1) f.BackgroundColor3 = W f.BorderSizePixel = 0 f.ZIndex = 1 f.Parent = menu
  local g = Instance.new("UIGradient")
  g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(c[4], .86), NumberSequenceKeypoint.new(.5, 1), NumberSequenceKeypoint.new(c[5], .9), NumberSequenceKeypoint.new(1, 1)})
  g.Rotation = c[1] g.Parent = f
  LAY[i] = {f = f, g = g, r = c[1], s = c[2], p = c[3]}
  skin(f, function() g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, th.m:Lerp(B, .45)), ColorSequenceKeypoint.new(.5, th.m), ColorSequenceKeypoint.new(1, th.m:Lerp(B, .3))}) end)
end
local fade = Instance.new("Frame") fade.Size = UDim2.fromScale(1, 1) fade.BorderSizePixel = 0 fade.ZIndex = 3 fade.Parent = menu
local fg = Instance.new("UIGradient") fg.Rotation = 90
fg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, .88), NumberSequenceKeypoint.new(1, .2)})
fg.Parent = fade
skin(fade, function() fade.BackgroundColor3 = th.bg end)
for i = 1, 44 do
  local f = Instance.new("Frame") f.BorderSizePixel = 0 f.ZIndex = 2 f.Parent = menu
  PT[i] = {f = f, c = Instance.new("UICorner", f), x = math.random(), y = math.random(), vx = 0, vy = 0, ph = math.random() * 6.28, sp = .8 + math.random() * 2}
end
skin(menu, function() for _, p in ipairs(PT) do p.f.BackgroundColor3 = th.tx end end)
function U.setMode()
  local m = MODES[S.bgm] or MODES.Aurora
  for i, p in ipairs(PT) do
    p.f.Visible = i <= m.n
    if i <= m.n then
      p.z = m.s[1] + math.random() * (m.s[2] - m.s[1])
      p.f.Size = UDim2.fromOffset(p.z, m.h or p.z)
      p.vx = m.vx and (m.vx[1] + math.random() * (m.vx[2] - m.vx[1])) or 0
      p.vy = m.vy and (m.vy[1] + math.random() * (m.vy[2] - m.vy[1])) or 0
      p.c.CornerRadius = UDim.new(m.rd and 1 or 0, 0)
      if not m.tw then p.f.BackgroundTransparency = .5 end
    end
  end
  for _, l in ipairs(LAY) do l.f.Visible = S.bgm == "Aurora" end
end
local t0 = os.clock()
U.cn[#U.cn + 1] = RS.RenderStepped:Connect(function(dt)
  if not menu.Visible then return end
  local t = os.clock() - t0
  mg.Rotation = t * 50
  local m = MODES[S.bgm] or MODES.Aurora
  if S.bgm == "Aurora" then for _, l in ipairs(LAY) do l.g.Offset = Vector2.new(math.sin(t * l.s + l.p) * .4, 0) l.g.Rotation = l.r + math.sin(t * l.s * .6 + l.p) * 14 end end
  for i = 1, m.n do
    local p = PT[i]
    p.x = (p.x + p.vx * dt) % 1 p.y = (p.y + p.vy * dt) % 1
    p.f.Position = UDim2.fromScale(p.x + (m.sw and math.sin(t + p.ph) * .012 or 0), p.y)
    if m.tw then p.f.BackgroundTransparency = .15 + .85 * (.5 + .5 * math.sin(t * p.sp + p.ph)) end
  end
  if S.spin and U.cl then U.ang = (U.ang or 0) + dt * 1.1 pcall(function() U.cl:PivotTo(CFrame.Angles(0, U.ang, 0)) end) end
end)

local title = lbl(menu, "Aerial", 20, UDim2.fromOffset(10, 4), UDim2.fromOffset(130, 28), Enum.TextXAlignment.Left, true)
local tg = Instance.new("UIGradient") tg.Parent = title
skin(title, function() tg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, W), ColorSequenceKeypoint.new(.5, th.m), ColorSequenceKeypoint.new(1, W)}) end)
U.cn[#U.cn + 1] = RS.RenderStepped:Connect(function() tg.Offset = Vector2.new(math.sin((os.clock() - t0) * 1.5) * .6, 0) end)
local stl = lbl(menu, "", 11, UDim2.fromOffset(150, 8), UDim2.fromOffset(362, 18), Enum.TextXAlignment.Right, true)
function U.st(t) stl.Text = t end
local tst = lbl(menu, "", 13, UDim2.fromOffset(176, 288), UDim2.fromOffset(310, 22), nil, true)
tst.ZIndex = 15 tst.TextTransparency = 1
function U.toast(t)
  tst.Text = t tst.TextTransparency = 0 U.st(t)
  local id = (U.tid or 0) + 1 U.tid = id
  task.delay(1.6, function() if U.tid == id then TS:Create(tst, TweenInfo.new(.4), {TextTransparency = 1}):Play() end end)
end

-- AVATAR BOX (live preview built from what you are wearing) ---------
local av = Instance.new("Frame") av.Position = UDim2.fromOffset(8, 34) av.Size = UDim2.fromOffset(140, 196) av.ClipsDescendants = true av.ZIndex = 5 av.Parent = menu
crn(av, 12) stk(av, .5) pnl(av, .45)
local vp = Instance.new("ViewportFrame") vp.BackgroundTransparency = 1 vp.Size = UDim2.new(1, 0, 1, -52) vp.ZIndex = 6 vp.Ambient = Color3.fromRGB(190, 190, 190) vp.LightColor = Color3.fromRGB(255, 255, 255) vp.Parent = av
local vc = Instance.new("Camera") vc.FieldOfView = 38 vc.CFrame = CFrame.new(Vector3.new(0, .2, 9.5), Vector3.new(0, .2, 0)) vc.Parent = vp vp.CurrentCamera = vc

-- builds a HumanoidDescription from your real avatar + everything you equipped (+ try-on items)
function U.desc(grey, withTry)
  local h = hum()
  local ok, d = pcall(function() return h:GetAppliedDescription() end)
  if not ok or not d then d = Instance.new("HumanoidDescription") end
  local function put(kind, id)
    local def = CAT[kind]
    if def[2] then
      local cur = tostring(d[def[2]])
      for s in cur:gmatch("[^,]+") do if s == tostring(id) then return end end
      d[def[2]] = (cur ~= "" and (cur .. ",") or "") .. id
    elseif kind == "Shirt" then d.Shirt = id
    elseif kind == "Pants" then d.Pants = id
    elseif kind == "TShirt" then d.GraphicTShirt = id end
  end
  for _, e in ipairs(U.eq) do
    if e.kind == "Part" then pcall(function() d[e.prop] = e.id end) else put(e.kind, e.id) end
  end
  if withTry then for _, t in ipairs(U.tr) do put(t.kind, t.id) end end
  if grey then
    local g = Color3.fromRGB(165, 165, 172)
    d.HeadColor, d.TorsoColor, d.LeftArmColor, d.RightArmColor, d.LeftLegColor, d.RightLegColor = g, g, g, g, g, g
  end
  return d
end
function U.pv()
  U.pgen = (U.pgen or 0) + 1
  local gen = U.pgen
  task.delay(.15, function()
    if U.pgen ~= gen then return end
    local h = hum()
    if not h then return end
    local rt = S.rig == "R6" and Enum.HumanoidRigType.R6 or h.RigType
    local ok, rig = pcall(Players.CreateHumanoidModelFromDescription, Players, U.desc(S.grey, true), rt)
    if not ok or not rig then return U.st("Preview failed") end
    if U.pgen ~= gen then rig:Destroy() return end
    for _, x in ipairs(rig:GetDescendants()) do if x:IsA("BasePart") then x.Anchored = true end end
    if U.cl then U.cl:Destroy() end
    rig.Parent = vp U.cl = rig
    pcall(function() rig:PivotTo(CFrame.Angles(0, U.ang or 0, 0)) end)
  end)
end
function U.tryToggle(kind, id, name)
  for i, t in ipairs(U.tr) do
    if t.id == id then table.remove(U.tr, i) U.pv() return U.st("Removed from preview") end
  end
  if CAT[kind][3] then for i = #U.tr, 1, -1 do if U.tr[i].kind == kind then table.remove(U.tr, i) end end end
  U.tr[#U.tr + 1] = {kind = kind, id = id, name = name}
  U.pv()
  U.st("Previewing " .. tostring(name or "item") .. " (tap Wear to put it on)")
end
-- the real thing: saves the look to your Roblox account so everyone sees it after you reset
function U.publish()
  local h = hum()
  if not h then return U.st("No character") end
  local d = U.desc(false, false)
  for k, id in pairs(U.ch) do pcall(function() d[k .. "Animation"] = id end) end
  local ok = pcall(AES.PromptSaveAvatar, AES, d, h.RigType)
  U.st(ok and "Confirm the Roblox prompt, then reset your character" or "Couldn't open the save prompt")
end
pcall(function()
  U.cn[#U.cn + 1] = AES.PromptSaveAvatarCompleted:Connect(function(res)
    U.st(res == Enum.AvatarPromptResult.Success and "Saved! Reset your character so everyone sees it" or ("Not saved: " .. tostring(res)))
  end)
end)

-- EQUIPPED BAR ------------------------------------------------------
lbl(menu, "equipped", 11, UDim2.fromOffset(10, 232), UDim2.fromOffset(100, 14), Enum.TextXAlignment.Left)
local bar = Instance.new("ScrollingFrame") bar.Position = UDim2.fromOffset(8, 248) bar.Size = UDim2.fromOffset(140, 66) bar.BorderSizePixel = 0
bar.ScrollBarThickness = 0 bar.ScrollingDirection = Enum.ScrollingDirection.X bar.AutomaticCanvasSize = Enum.AutomaticSize.X bar.CanvasSize = UDim2.new() bar.ZIndex = 6 bar.Parent = menu
crn(bar, 12) stk(bar, .5) pnl(bar, .45)
local bl = Instance.new("UIListLayout") bl.FillDirection = Enum.FillDirection.Horizontal bl.Padding = UDim.new(0, 4) bl.VerticalAlignment = Enum.VerticalAlignment.Center bl.SortOrder = Enum.SortOrder.LayoutOrder bl.Parent = bar
Instance.new("UIPadding", bar).PaddingLeft = UDim.new(0, 4)

-- RIGHT SIDE: strips, search row, grid, holder -----------------------
local function strip(y)
  local f = Instance.new("ScrollingFrame") f.BackgroundTransparency = 1 f.BorderSizePixel = 0 f.Position = UDim2.fromOffset(156, y) f.Size = UDim2.fromOffset(356, 26)
  f.ScrollBarThickness = 0 f.ScrollingDirection = Enum.ScrollingDirection.X f.AutomaticCanvasSize = Enum.AutomaticSize.X f.CanvasSize = UDim2.new() f.ZIndex = 6 f.Parent = menu
  local l = Instance.new("UIListLayout") l.FillDirection = Enum.FillDirection.Horizontal l.Padding = UDim.new(0, 4) l.SortOrder = Enum.SortOrder.LayoutOrder l.Parent = f
  return f
end
function U.fill(f, names, cb)
  for _, c in ipairs(f:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
  f.CanvasPosition = Vector2.new()
  local r = {}
  for i, n in ipairs(names) do
    local b = btn(f, n, UDim2.new(), UDim2.fromOffset(60, 26)) b.LayoutOrder = i r[n] = b
    b.MouseButton1Click:Connect(function() cb(n) end)
  end
  return r
end
U.ms, U.ss = strip(34), strip(64)
local sr = Instance.new("Frame") sr.BackgroundTransparency = 1 sr.Size = UDim2.fromOffset(356, 26) sr.ZIndex = 6 sr.Parent = menu
U.sr, U.bx = sr, tbx(sr, UDim2.new(), UDim2.new(1, -84, 1, 0))
U.gb = btn(sr, "search", UDim2.new(1, -76, 0, 0), UDim2.new(0, 76, 1, 0), true)
local grid = Instance.new("ScrollingFrame") grid.BackgroundTransparency = 1 grid.BorderSizePixel = 0 grid.ScrollBarThickness = 3
grid.AutomaticCanvasSize = Enum.AutomaticSize.Y grid.CanvasSize = UDim2.new() grid.ZIndex = 6 grid.Parent = menu
skin(grid, function() grid.ScrollBarImageColor3 = th.m end)
local gl = Instance.new("UIGridLayout") gl.SortOrder = Enum.SortOrder.LayoutOrder gl.CellPadding = UDim2.fromOffset(4, 4) gl.Parent = grid
Instance.new("UIPadding", grid).PaddingLeft = UDim.new(0, 2)
U.grid, U.gl = grid, gl
local hold = Instance.new("Frame") hold.BackgroundTransparency = 1 hold.Position = UDim2.fromOffset(156, 94) hold.Size = UDim2.fromOffset(356, 220) hold.ZIndex = 6 hold.Visible = false hold.Parent = menu
local ORD = 0
function U.clr()
  ORD = 0 U.mo = nil
  for _, c in ipairs(grid:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
  grid.CanvasPosition = Vector2.new()
end
function U.cell(img, name, fn) -- transparent item with its name under it
  ORD += 1
  local f = Instance.new("Frame") f.BackgroundTransparency = 1 f.LayoutOrder = ORD f.ZIndex = 7 f.Parent = grid
  local b = Instance.new("ImageButton") b.Image = img b.BackgroundTransparency = 1 b.BorderSizePixel = 0 b.ScaleType = Enum.ScaleType.Fit
  b.Size = UDim2.new(1, 0, 1, -20) b.ZIndex = 7 b.Parent = f
  local l = lbl(f, (name ~= "" and name or "?"), 9, UDim2.new(0, 0, 1, -20), UDim2.new(1, 0, 0, 20), nil, true)
  l.TextWrapped = true l.TextTruncate = Enum.TextTruncate.AtEnd l.TextYAlignment = Enum.TextYAlignment.Top l.ZIndex = 7
  b.MouseButton1Click:Connect(function() pop(b) U.toast(name ~= "" and name or "?") fn() end)
  return b
end
function U.item(text, fn)
  ORD += 1
  local b = btn(grid, text, UDim2.new(), UDim2.new(), true) b.LayoutOrder = ORD
  b.MouseButton1Click:Connect(fn)
  return b
end
function U.more(add)
  if U.mo then U.mo:Destroy() U.mo = nil end
  local pgs = U.pages
  if pgs and not pgs.IsFinished then
    local b = btn(grid, "more", UDim2.new(), UDim2.new()) b.LayoutOrder = 99999 U.mo = b
    b.MouseButton1Click:Connect(function()
      if pgs ~= U.pages then return end
      if pcall(pgs.AdvanceToNextPageAsync, pgs) then add(pgs:GetCurrentPage()) U.more(add) else U.st("No more results") end
    end)
  end
end
function U.catalog(setup, add, pre)
  local m, s = U.m, U.sub[U.m]
  U.st("...")
  local p = CatalogSearchParams.new()
  p.SearchKeyword = U.bx.Text p.SortType = Enum.CatalogSortType.Relevance
  setup(p)
  local ok, res = pcall(AES.SearchCatalog, AES, p)
  if U.m ~= m or U.sub[m] ~= s then return end
  U.clr() gl.CellSize = UDim2.fromOffset(66, 88)
  if pre then pre() end
  if not ok or not res then return U.st("Search failed") end
  U.pages = res
  add(res:GetCurrentPage())
  U.more(add)
  U.st("")
end

-- CORE: equip / take off / body parts -------------------------------
local function find(objs, cls)
  for _, o in ipairs(objs) do
    if o:IsA(cls) then return o end
    local d = o:FindFirstChildWhichIsA(cls, true)
    if d then return d end
  end
end
local function hideHead(on)
  local h = lp.Character and lp.Character:FindFirstChild("Head")
  if not h then return end
  h.Transparency = on and 1 or 0
  for _, d in ipairs(h:GetChildren()) do if d:IsA("Decal") then d.Transparency = on and 1 or 0 end end
end
local function attach(c, acc)
  local h = acc:FindFirstChild("Handle")
  if not h then return false end
  h.Anchored = false h.CanCollide = false h.Massless = true
  for _, a in ipairs(h:GetChildren()) do
    if a:IsA("Attachment") then
      for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("Attachment") and d.Name == a.Name and d.Parent:IsA("BasePart") and not d:IsDescendantOf(acc) then
          local w = Instance.new("Weld") w.Name = "AccessoryWeld" w.Part0 = d.Parent w.Part1 = h w.C0 = d.CFrame w.C1 = a.CFrame
          w:SetAttribute("an", a.Name) w.Parent = h acc.Parent = c
          return true
        end
      end
    end
  end
  return false
end
local function sig()
  local c, t = lp.Character, {}
  if not c then return "" end
  for _, d in ipairs(c:GetDescendants()) do if d:IsA("CharacterMesh") or d:IsA("MeshPart") or d:IsA("SpecialMesh") then t[#t + 1] = tostring(d.MeshId) end end
  table.sort(t) return table.concat(t, "|")
end
local function fnd(roots, n, cls)
  for _, r in ipairs(roots) do
    if r.Name == n and r:IsA(cls) then return r end
    for _, d in ipairs(r:GetDescendants()) do if d.Name == n and d:IsA(cls) then return d end end
  end
end
-- copies one body part (from a temp rig or loaded asset) onto your character; returns undo fn
function U.swap(roots, prop, style)
  local c, h = lp.Character, hum()
  if not (c and h) then return nil end
  local und, ok, want = {}, false, BP[prop]
  local function cmFrom()
    for _, r in ipairs(roots) do
      if r:IsA("CharacterMesh") and r.BodyPart == want then return r end
      for _, d in ipairs(r:GetDescendants()) do if d:IsA("CharacterMesh") and d.BodyPart == want then return d end end
    end
  end
  if h.RigType == Enum.HumanoidRigType.R6 then
    local src = cmFrom()
    if src then
      local old = {}
      for _, o in ipairs(c:GetChildren()) do if o:IsA("CharacterMesh") and o.BodyPart == want then old[#old + 1] = o:Clone() o:Destroy() end end
      local n = src:Clone() n.Parent = c
      und[1] = function() n:Destroy() for _, o in ipairs(old) do o.Parent = c end end
      ok = true
    elseif prop == "Head" then
      local rh, ch = fnd(roots, "Head", "BasePart"), c:FindFirstChild("Head")
      local m = rh and rh:FindFirstChildWhichIsA("SpecialMesh")
      if m and ch and m.MeshId ~= "" then
        local o = ch:FindFirstChildWhichIsA("SpecialMesh") local keep = o and o:Clone() if o then o:Destroy() end
        local n = m:Clone() n.Parent = ch
        und[1] = function() n:Destroy() if keep then keep.Parent = ch end end
        ok = true
      end
    end
  else
    local ps = {}
    for _, nm in ipairs(G15[prop]) do local tp = c:FindFirstChild(nm) if tp and tp:IsA("MeshPart") then ps[#ps + 1] = tp end end
    local function save(tp, rp)
      local m0, t0, s0, tr0, at = tp.MeshId, tp.TextureID, tp.Size, tp.Transparency, {}
      local sa = tp:FindFirstChildOfClass("SurfaceAppearance") local sac = sa and sa:Clone()
      local swapped = false
      if rp then
        for _, a in ipairs(rp:GetChildren()) do
          local ta = tp:FindFirstChild(a.Name)
          if a:IsA("Attachment") and ta and ta:IsA("Attachment") then at[ta] = ta.CFrame ta.CFrame = a.CFrame end
        end
        local rs = rp:FindFirstChildOfClass("SurfaceAppearance")
        if rs then if sa then sa:Destroy() end rs:Clone().Parent = tp swapped = true end
      end
      und[#und + 1] = function()
        tp.MeshId = m0 tp.TextureID = t0 tp.Size = s0 tp.Transparency = tr0
        for a, cf in pairs(at) do a.CFrame = cf end
        if swapped then local x = tp:FindFirstChildOfClass("SurfaceAppearance") if x then x:Destroy() end if sac then sac.Parent = tp end end
      end
    end
    local cm = style == "R6" and cmFrom()
    if cm and ps[1] then -- R6 style: one whole-limb mesh on the first piece, other pieces hidden
      for i, tp in ipairs(ps) do save(tp) if i > 1 then tp.Transparency = 1 end end
      pcall(function() ps[1].MeshId = cm.MeshId ps[1].TextureID = cm.OverlayTextureId ps[1].Size = WHOLE[prop] end)
      ok = ps[1].MeshId == cm.MeshId
    else
      local pr = {}
      for _, tp in ipairs(ps) do local rp = fnd(roots, tp.Name, "MeshPart") if rp and rp.MeshId ~= "" then pr[#pr + 1] = {rp, tp} end end
      local same = #pr > 1 -- identical mesh on every piece = a whole-limb mesh
      for i = 2, #pr do if pr[i][1].MeshId ~= pr[1][1].MeshId then same = false end end
      for i, x in ipairs(pr) do
        save(x[2], x[1])
        if same and i > 1 then
          x[2].Transparency = 1 ok = true
        else
          pcall(function() x[2].MeshId = x[1].MeshId x[2].TextureID = x[1].TextureID x[2].Size = x[1].Size end)
          if x[2].MeshId == x[1].MeshId then ok = true end
        end
      end
      if ok then pcall(function() h:BuildRigFromAttachments() end) end
    end
  end
  if not ok then return nil end
  return function()
    for i = #und, 1, -1 do pcall(und[i]) end
    pcall(function() if h.RigType == Enum.HumanoidRigType.R15 then h:BuildRigFromAttachments() end end)
  end
end
function U.setPart(prop, id, tu, tag, rig, name)
  local h = hum()
  if not h then U.st("No character") return false end
  for i = #U.eq, 1, -1 do
    local e = U.eq[i]
    if e.kind == "Part" and e.prop == prop then if e.undo then pcall(e.undo) end table.remove(U.eq, i) end
  end
  local und
  if rig then
    und = U.swap({rig}, prop, S.rig)
  else
    local d0 = Instance.new("HumanoidDescription") d0[prop] = id
    local rt = S.rig == "R6" and Enum.HumanoidRigType.R6 or h.RigType
    local ok, r = pcall(Players.CreateHumanoidModelFromDescription, Players, d0, rt)
    if ok and r then und = U.swap({r}, prop, S.rig) r:Destroy() end
  end
  if not und then
    local o, objs = pcall(game.GetObjects, game, "rbxassetid://" .. id)
    if o and objs then und = U.swap(objs, prop, S.rig) end
  end
  if not und then
    local before = sig()
    local ok2 = pcall(function() local d = h:GetAppliedDescription() d[prop] = id h:ApplyDescription(d) end)
    if not ok2 or sig() == before then U.refresh() U.st("Game blocked it (no change)") return false end
  end
  if prop == "Head" then hideHead(id == HEADLESS) end
  U.eq[#U.eq + 1] = {kind = "Part", prop = prop, id = id, thumb = tu or thumb(id), tag = tag or TAG[prop], name = name, undo = und}
  if not und then U.restore() else U.refresh() end
  return true
end
function U.resolve(id)
  if U.bc[id] then return U.bc[id] end
  local parts = {}
  local ok, info = pcall(MP.GetProductInfo, MP, id, Enum.InfoType.Bundle)
  local items = ok and type(info) == "table" and info.Items or nil
  if not items then
    local o2, d = pcall(AES.GetItemDetails, AES, id, Enum.AvatarItemType.Bundle)
    items = o2 and type(d) == "table" and (d.BundledItems or d.Items) or nil
  end
  for _, it in ipairs(items or {}) do
    if it.Type == "UserOutfit" then
      local o, d = pcall(Players.GetHumanoidDescriptionFromOutfitId, Players, it.Id)
      if o and d then for _, pr in pairs(PART) do if d[pr] ~= 0 and not parts[pr] then parts[pr] = d[pr] end end end
    elseif it.Id then
      local o, ai = pcall(MP.GetProductInfo, MP, it.Id, Enum.InfoType.Asset)
      if o and ai then for pr, tid in pairs(ATID) do if ai.AssetTypeId == tid and not parts[pr] then parts[pr] = it.Id end end end
    end
  end
  if next(parts) then U.bc[id] = parts end
  return parts
end
function U.applyB(id, prop, tu, nm) -- prop nil = the whole package (head, torso, arms, legs)
  U.st("Reading bundle...")
  local parts = U.resolve(id)
  if not next(parts) then return U.st("Couldn't read this bundle") end
  local h = hum()
  if not h then return U.st("No character") end
  local d0 = Instance.new("HumanoidDescription")
  for pr, aid in pairs(parts) do if not prop or pr == prop then pcall(function() d0[pr] = aid end) end end
  local rt = S.rig == "R6" and Enum.HumanoidRigType.R6 or h.RigType
  local ok, rig = pcall(Players.CreateHumanoidModelFromDescription, Players, d0, rt) -- one rig for the whole package
  local n = 0
  for pr, aid in pairs(parts) do
    if not prop or pr == prop then if U.setPart(pr, aid, tu, nil, ok and rig or nil, nm) then n += 1 end end
  end
  if ok and rig then rig:Destroy() end
  U.st(n > 0 and ("Applied " .. n .. " part(s)") or "Bundle has no such part")
end

-- accessories & clothes ---------------------------------------------
function U.edAcc(e) -- apply stored resize + color to an accessory
  local a = e.inst
  local h = a and a.Parent and a:FindFirstChild("Handle")
  if not h then return end
  local m = h:FindFirstChildWhichIsA("SpecialMesh")
  if not h:GetAttribute("os") then
    h:SetAttribute("os", h.Size) h:SetAttribute("oc", h.Color)
    h:SetAttribute("ot", h:IsA("MeshPart") and h.TextureID or (m and m.TextureId or ""))
    if m then h:SetAttribute("om", m.Scale) h:SetAttribute("ov", m.VertexColor) end
    for _, x in ipairs(h:GetChildren()) do if x:IsA("Attachment") then x:SetAttribute("op", x.Position) end end
  end
  local f = e.sc or 1
  if m then m.Scale = h:GetAttribute("om") * f else h.Size = h:GetAttribute("os") * f end
  local w = h:FindFirstChild("AccessoryWeld")
  for _, x in ipairs(h:GetChildren()) do
    if x:IsA("Attachment") and x:GetAttribute("op") then
      x.Position = x:GetAttribute("op") * f
      if w and w:GetAttribute("an") == x.Name then w.C1 = x.CFrame end
    end
  end
  local c = e.cl and c3(e.cl) or h:GetAttribute("oc")
  h.Color = c
  if m then m.VertexColor = e.cl and Vector3.new(c.R, c.G, c.B) or h:GetAttribute("ov") end
  local tex = (e.sd and e.cl) and "" or h:GetAttribute("ot")
  if m then m.TextureId = tex elseif h:IsA("MeshPart") then h.TextureID = tex end
end
function U.off(e)
  for i, x in ipairs(U.eq) do if x == e then table.remove(U.eq, i) break end end
  if U.sel == e then U.sel = nil end
  if e.kind == "Part" then
    if e.undo then pcall(e.undo) else
      pcall(function() local h = hum() local own = Players:GetHumanoidDescriptionFromUserId(lp.UserId) local d = h:GetAppliedDescription() d[e.prop] = own[e.prop] h:ApplyDescription(d) end)
      U.restore()
    end
    if e.prop == "Head" then hideHead(false) end
  elseif e.inst then e.inst:Destroy()
  elseif e.via == "desc" then
    pcall(function()
      local h = hum() local d = h:GetAppliedDescription() local pr, keep = CAT[e.kind][2], {}
      for s in tostring(d[pr]):gmatch("[^,]+") do if s ~= tostring(e.id) then keep[#keep + 1] = s end end
      d[pr] = table.concat(keep, ",") h:ApplyDescription(d)
    end)
  end
end
function U.equip(kind, id, name)
  local c, h = lp.Character, hum()
  if not (c and h) then return U.st("No character") end
  for _, e in ipairs(U.eq) do if e.id == id then return U.st("Already equipped") end end
  local def = CAT[kind]
  local o, objs = pcall(game.GetObjects, game, "rbxassetid://" .. id)
  local en = {kind = kind, id = id, name = name}
  if def[3] then
    local it = o and objs and find(objs, def[3])
    if not it then return U.st("Couldn't load item") end
    for i = #U.eq, 1, -1 do if U.eq[i].kind == kind then U.off(U.eq[i]) end end
    local old = c:FindFirstChildOfClass(def[3]) if old then old:Destroy() end
    it.Parent = c en.inst = it
  else
    local acc = o and objs and find(objs, "Accessory")
    if acc then
      if not attach(c, acc) then pcall(function() h:AddAccessory(acc) end) end
      if acc.Parent == c then en.inst = acc else acc:Destroy() end
    end
    if not en.inst then
      local ok = pcall(function() local d = h:GetAppliedDescription() local cur = d[def[2]] d[def[2]] = (cur ~= "" and (cur .. ",") or "") .. id h:ApplyDescription(d) end)
      if not ok then return U.st("Couldn't equip") end
      en.via = "desc"
    end
  end
  U.eq[#U.eq + 1] = en
  U.refresh()
  return en
end
function U.restore()
  local old = U.eq
  U.eq = {}
  for _, e in ipairs(old) do if e.inst and not e.inst.Parent then U.equip(e.kind, e.id, e.name) else U.eq[#U.eq + 1] = e end end
  U.refresh()
end

-- equipped bar + popup (Keep / Edit / Take off) ---------------------
function U.closeP()
  if not U.pop then return end
  local p = U.pop U.pop = nil
  TS:Create(p, TweenInfo.new(.12), {Size = UDim2.fromOffset(10, 4)}):Play()
  task.delay(.14, function() p:Destroy() end)
end
local function openPop(b, e)
  local same = U.pop and U.pop:GetAttribute("k") == tostring(e.id)
  U.closeP()
  U.toast(e.name or e.tag or "?")
  if same then return end
  TS:Create(b, TweenInfo.new(.12, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(46, 46)}):Play()
  task.delay(.14, function() if b.Parent then TS:Create(b, TweenInfo.new(.12), {Size = UDim2.fromOffset(40, 40)}):Play() end end)
  local x = math.clamp((b.AbsolutePosition.X - menu.AbsolutePosition.X + b.AbsoluteSize.X / 2) / us.Scale, 80, 440)
  local y = (b.AbsolutePosition.Y - menu.AbsolutePosition.Y) / us.Scale - 4
  local p = Instance.new("Frame") p.AnchorPoint = Vector2.new(.5, 1) p.Position = UDim2.fromOffset(x, y) p.Size = UDim2.fromOffset(10, 4)
  p.BackgroundTransparency = 1 p.ClipsDescendants = true p.ZIndex = 20 p:SetAttribute("k", tostring(e.id)) p.Parent = menu U.pop = p
  local function mk(t, col, i, fn)
    local q = btn(p, t, UDim2.new((i - 1) / 3, 1, 0, 0), UDim2.new(1 / 3, -2, 1, 0))
    q:SetAttribute("fx", true) q.BackgroundColor3 = col q.BackgroundTransparency = 0 q.TextColor3 = W q.MouseButton1Click:Connect(fn)
  end
  mk("keep", Color3.fromRGB(50, 190, 90), 1, U.closeP)
  mk("edit", Color3.fromRGB(60, 130, 230), 2, function() U.closeP() if e.inst then U.sel = e U.go("edit") else U.st("Only accessories can be edited") end end)
  mk("takeoff", Color3.fromRGB(225, 55, 55), 3, function() U.closeP() U.off(e) U.refresh() end)
  TS:Create(p, TweenInfo.new(.18, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(168, 24)}):Play()
  task.delay(4, function() if U.pop == p then U.closeP() end end)
end
function U.refresh()
  U.closeP()
  for _, c in ipairs(bar:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
  for i, e in ipairs(U.eq) do
    local f = Instance.new("Frame") f.Size = UDim2.fromOffset(50, 60) f.LayoutOrder = i f.BackgroundTransparency = 1 f.ZIndex = 7 f.Parent = bar
    local b = Instance.new("ImageButton") b.Size = UDim2.fromOffset(40, 40) b.Position = UDim2.fromOffset(5, 0) b.Image = e.thumb or thumb(e.id)
    b.BackgroundTransparency = 1 b.BorderSizePixel = 0 b.ZIndex = 7 b.Parent = f
    if e.tag then local t = lbl(b, e.tag, 9, UDim2.new(0, 0, 0, 0), UDim2.fromOffset(14, 12), nil, true) t.ZIndex = 9 end
    local nm = lbl(f, e.name or e.tag or "?", 8, UDim2.fromOffset(0, 41), UDim2.new(1, 0, 0, 19), nil, true)
    nm.TextWrapped = true nm.TextTruncate = Enum.TextTruncate.AtEnd nm.TextYAlignment = Enum.TextYAlignment.Top nm.ZIndex = 7
    b.MouseButton1Click:Connect(function() openPop(b, e) end)
  end
  U.pv()
end

-- toolbar inside the avatar box
local function tb(k, x, y, fn)
  local b = btn(av, k, UDim2.new(0, x, 1, y), UDim2.fromOffset(43, 22)) b.ZIndex = 8
  b.MouseButton1Click:Connect(function() fn(b) end)
  return b
end
setOn(tb("grey", 4, -48, function(b) S.grey = not S.grey setOn(b, S.grey) U.save() U.pv() end), S.grey)
tb("try", 49, -48, function(b) U.tryOn = not U.tryOn setOn(b, U.tryOn) if not U.tryOn then U.tr = {} U.pv() end U.st(U.tryOn and "Try mode: tap items to preview them, then tap Wear" or "Try mode off") end)
tb("wear", 94, -48, function()
  local l = U.tr U.tr = {}
  for _, t in ipairs(l) do U.equip(t.kind, t.id, t.name) end
  U.pv()
end)
tb("clear", 4, -25, function() local l = {} for _, e in ipairs(U.eq) do l[#l + 1] = e end for _, e in ipairs(l) do U.off(e) end U.tr = {} U.refresh() U.st("Cleared") end)
tb("undo", 49, -25, function() local e = U.eq[#U.eq] if e then U.off(e) U.refresh() end end)
setOn(tb("spin", 94, -25, function(b) S.spin = not S.spin setOn(b, S.spin) U.save() end), S.spin)
local pb = btn(av, "publish", UDim2.new(1, -50, 0, 4), UDim2.fromOffset(46, 18)) pb.ZIndex = 8
pb.MouseButton1Click:Connect(U.publish)
-- R6 / R15 button: Auto = your real rig, R6 = whole-limb meshes (Korblox on R15), R15 = per-piece meshes
local rb = btn(av, "", UDim2.fromOffset(4, 4), UDim2.fromOffset(84, 18), true) rb.ZIndex = 8
function U.rigLbl()
  local h = hum()
  local real = h and (h.RigType == Enum.HumanoidRigType.R6 and "R6" or "R15") or "?"
  rb.Text = "Rig: " .. (S.rig == "Auto" and ("Auto " .. real) or S.rig)
end
rb.MouseButton1Click:Connect(function()
  S.rig = ({Auto = "R6", R6 = "R15", R15 = "Auto"})[S.rig] or "Auto"
  U.save() U.rigLbl() U.pv()
  U.st(S.rig == "R6" and "R6 style: one whole-limb mesh (best for Korblox on R15)" or S.rig == "R15" and "R15 style: per-piece meshes" or "Auto: uses your real rig")
end)
U.rigLbl()

-- PAGES: items / chars / emotes / anims / configs -------------------
function U.cat()
  local k = U.sub[U.m]
  U.catalog(function(p) p.AssetTypes = {CAT[k][1]} end, function(items)
    for _, it in ipairs(items) do
      if tostring(it.ItemType):find("Asset") then
        U.cell(thumb(it.Id), it.Name or "", function()
          if U.tryOn then U.tryToggle(k, it.Id, it.Name) else U.equip(k, it.Id, it.Name) end
        end)
      end
    end
  end)
end
function U.char()
  local s = U.sub.chars
  local prop = PART[s]
  U.seen = {} -- one entry per package, no repeats
  U.catalog(function(p)
    pcall(function() p.BundleTypes = {Enum.BundleType.BodyParts} end)
    pcall(function() p.IncludeOffSale = true end)
    if S.off then pcall(function() p.CreatorName = "Roblox" end) end
  end, function(items)
    for _, it in ipairs(items) do
      if tostring(it.ItemType):find("Bundle") then
        local k = (tostring(it.Name or ""):lower():gsub("%W", ""))
        if k ~= "" and not U.seen[k] and not U.seen[it.Id] and not k:find("korblox") and not k:find("headless") then
          U.seen[k] = true U.seen[it.Id] = true
          local tu = "rbxthumb://type=BundleThumbnail&id=" .. it.Id .. "&w=150&h=150"
          U.cell(tu, it.Name or "", function() U.applyB(it.Id, prop, tu, it.Name) end)
        end
      end
    end
  end, function()
    if s == "bundles" or s == "RL" then local pn = PINS.RL U.cell(thumb(pn[3]), pn[1], function() U.setPart(pn[2], pn[3], nil, nil, nil, pn[1]) end) end
    if s == "bundles" or s == "H" then local pn = PINS.H U.cell(thumb(pn[3]), pn[1], function() U.setPart(pn[2], pn[3], nil, nil, nil, pn[1]) end) end
  end)
end
function U.wheel()
  local h = hum()
  if not h then return false end
  local em, eqp = {}, {}
  for i, e in ipairs(U.wl) do em[e[1]] = {e[2]} eqp[i] = e[1] end
  return pcall(function()
    local hd = h:FindFirstChildOfClass("HumanoidDescription")
    if hd then hd:SetEmotes(em) hd:SetEquippedEmotes(eqp)
    else local d = h:GetAppliedDescription() d:SetEmotes(em) d:SetEquippedEmotes(eqp) h:ApplyDescription(d) end
  end)
end
function U.addEmote(id, name)
  if not U.wi then
    U.wi = true
    pcall(function()
      local hd = hum():FindFirstChildOfClass("HumanoidDescription")
      local em = hd:GetEmotes()
      for _, q in ipairs(hd:GetEquippedEmotes()) do if em[q.Name] then U.wl[#U.wl + 1] = {q.Name, em[q.Name][1]} end end
    end)
  end
  name = (tostring(name or ""):gsub("[^%w ]", "")):sub(1, 18)
  if name == "" then name = "Emote" .. id end
  for i, e in ipairs(U.wl) do if e[1] == name then table.remove(U.wl, i) break end end
  if #U.wl >= 8 then table.remove(U.wl, 1) end
  U.wl[#U.wl + 1] = {name, id}
  if U.wheel() then U.st("On your emote wheel: " .. name) pcall(function() hum():PlayEmote(name) end) else U.st("Couldn't update the wheel") end
end
function U.emo()
  if U.sub.emotes == "browse" then
    U.catalog(function(p) p.AssetTypes = {T.EmoteAnimation} end, function(items)
      for _, it in ipairs(items) do if tostring(it.ItemType):find("Asset") then U.cell(thumb(it.Id), it.Name or "", function() U.addEmote(it.Id, it.Name) end) end end
    end)
  else
    U.clr() gl.CellSize = UDim2.new(.5, -6, 0, 28)
    for i, e in ipairs(U.wl) do U.item(i .. ". " .. e[1], function() table.remove(U.wl, i) U.wheel() U.emo() end) end
    U.item("x " .. L("clear"), function() U.wl = {} U.wheel() U.emo() end)
    U.st("Tap a slot to remove it. Open the Roblox emote wheel to use them (R15)")
  end
end
local defs = {}
function U.anim(kind, id)
  local c = lp.Character
  local an = c and c:FindFirstChild("Animate")
  local f = an and an:FindFirstChild(AN[kind][1])
  if not f then return false end
  an.Disabled = true
  local h = hum()
  if h then for _, t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop() end end
  for i = 2, #AN[kind] do
    local a = f:FindFirstChild(AN[kind][i])
    if a then
      if not defs[a] then defs[a] = a.AnimationId end
      a.AnimationId = id and ("rbxassetid://" .. id) or defs[a]
    end
  end
  an.Disabled = false
  return true
end
function U.anims()
  local k = U.sub.anims
  U.clr() gl.CellSize = UDim2.new(.5, -6, 0, 28)
  local function add(text, id, raw)
    U.item(raw and text or L(text), function()
      if U.anim(k, id) then U.ch[k] = id U.toast(k .. ": " .. (raw and text or "Default")) else U.st("No Animate script found") end
    end)
  end
  add("default", nil, false)
  for _, p in ipairs(PK) do add(p.n, p[k], true) end
end
function U.snap()
  local c = {items = {}, parts = {}, anims = {}}
  for _, e in ipairs(U.eq) do
    if e.kind == "Part" then c.parts[#c.parts + 1] = {prop = e.prop, id = e.id, tag = e.tag, thumb = e.thumb, name = e.name}
    else c.items[#c.items + 1] = {kind = e.kind, id = e.id, name = e.name, sc = e.sc, cl = e.cl, sd = e.sd} end
  end
  for k, v in pairs(U.ch) do c.anims[k] = v end
  return c
end
function U.loadCfg(c)
  U.st("Loading config...")
  local l = {} for _, e in ipairs(U.eq) do l[#l + 1] = e end
  for _, e in ipairs(l) do U.off(e) end
  U.refresh()
  for _, p in ipairs(c.parts or {}) do U.setPart(p.prop, p.id, p.thumb, p.tag, nil, p.name) end
  for _, it in ipairs(c.items or {}) do
    local en = U.equip(it.kind, it.id, it.name)
    if en and en.inst and (it.sc or it.cl) then en.sc, en.cl, en.sd = it.sc, it.cl, it.sd U.edAcc(en) U.pv() end
  end
  for k in pairs(AN) do
    local id = c.anims and c.anims[k]
    if id then if U.anim(k, id) then U.ch[k] = id end elseif U.ch[k] then U.anim(k, nil) U.ch[k] = nil end
  end
  U.st("Config loaded")
end
function U.cfglist()
  U.clr() gl.CellSize = UDim2.fromOffset(112, 130)
  if #cfgs == 0 then U.item(L("cfgempty"), function() end) end
  for i, cf in ipairs(cfgs) do
    ORD += 1
    local card = Instance.new("Frame") card.LayoutOrder = ORD card.BorderSizePixel = 0 card.ZIndex = 7 card.Parent = grid
    crn(card, 10) stk(card, .6) pnl(card, .55)
    local ids = {}
    for _, p in ipairs(cf.data.parts or {}) do ids[#ids + 1] = p.thumb or thumb(p.id) end
    for _, it in ipairs(cf.data.items or {}) do ids[#ids + 1] = thumb(it.id) end
    for j = 1, 4 do
      local im = Instance.new("ImageLabel") im.BackgroundTransparency = 1 im.ZIndex = 8 im.Size = UDim2.fromOffset(44, 44)
      im.Position = UDim2.fromOffset(10 + ((j - 1) % 2) * 46, 4 + math.floor((j - 1) / 2) * 46) im.Image = ids[j] or "" im.Parent = card
    end
    local nl = lbl(card, cf.name, 11, UDim2.fromOffset(2, 98), UDim2.new(1, -4, 0, 14), nil, true) nl.TextTruncate = Enum.TextTruncate.AtEnd
    local function mb(t, x, fn) local b = btn(card, t, UDim2.fromOffset(x, 112), UDim2.fromOffset(34, 16)) b.ZIndex = 9 b.MouseButton1Click:Connect(fn) return b end
    setOn(mb("auto", 3, function() S.auto = (S.auto == cf.name) and "" or cf.name U.save() U.cfglist() end), S.auto == cf.name)
    mb("load", 39, function() task.spawn(U.loadCfg, cf.data) end)
    mb("delete", 75, function() table.remove(cfgs, i) if S.auto == cf.name then S.auto = "" U.save() end U.wr("configs.json", cfgs) U.cfglist() end)
  end
  U.st(canFS and "Configs save to your executor folder" or "No file access: configs last this session only")
end
function U.saveCfg()
  local n = (U.bx.Text:gsub("^%s+", ""):gsub("%s+$", ""))
  if n == "" then n = "Config " .. (#cfgs + 1) end
  local d, f = U.snap(), false
  for _, c in ipairs(cfgs) do if c.name == n then c.data = d f = true end end
  if not f then cfgs[#cfgs + 1] = {name = n, data = d} end
  local w = U.wr("configs.json", cfgs)
  U.bx.Text = "" U.cfglist() U.st(w and "Saved" or "Saved (this session only)")
end

-- HOLDER PAGES: edit + settings -------------------------------------
do
  local function page(id, scroll)
    local f = Instance.new(scroll and "ScrollingFrame" or "Frame") f.Size = UDim2.fromScale(1, 1) f.BackgroundTransparency = 1 f.BorderSizePixel = 0 f.Visible = false f.ZIndex = 6 f.Parent = hold
    if scroll then f.ScrollBarThickness = 3 f.AutomaticCanvasSize = Enum.AutomaticSize.Y f.CanvasSize = UDim2.new() end
    U.pg[id] = f return f
  end
  local function gridOf(f, cell) local g = Instance.new("UIGridLayout") g.CellSize = cell g.CellPadding = UDim2.fromOffset(4, 4) g.SortOrder = Enum.SortOrder.LayoutOrder g.Parent = f end
  local function swatch(f, y, h, cb)
    local sw = Instance.new("ScrollingFrame") sw.Position = UDim2.fromOffset(0, y) sw.Size = UDim2.new(1, 0, 0, h) sw.BackgroundTransparency = 1 sw.BorderSizePixel = 0
    sw.ScrollBarThickness = 3 sw.AutomaticCanvasSize = Enum.AutomaticSize.Y sw.CanvasSize = UDim2.new() sw.ZIndex = 6 sw.Parent = f
    gridOf(sw, UDim2.fromOffset(34, 34))
    for hx in PAL:gmatch("%x+") do
      local rgb = hexrgb(hx)
      local c = Instance.new("TextButton") c.Text = "" c.AutoButtonColor = false c.BorderSizePixel = 0 c.ZIndex = 7 c.BackgroundColor3 = c3(rgb) c.Parent = sw
      crn(c, 8) stk(c, .5)
      c.MouseButton1Click:Connect(function() pop(c) cb(rgb) end)
    end
  end
  local function hexrow(f, y, cb)
    local t = tbx(f, UDim2.fromOffset(0, y), UDim2.new(1, -84, 0, 26))
    U.hx = U.hx or {} U.hx[#U.hx + 1] = t
    local b = btn(f, "apply", UDim2.new(1, -76, 0, y), UDim2.new(0, 76, 0, 26))
    b.MouseButton1Click:Connect(function() local r = hexrgb(t.Text) if r then t.Text = "" cb(r) end end)
  end
  local function sect(f, y, key, opts, cols, get, set)
    lbl(f, key, 11, UDim2.fromOffset(2, y), UDim2.fromOffset(300, 16), Enum.TextXAlignment.Left)
    local st = {}
    for i, o in ipairs(opts) do
      local c, r = (i - 1) % cols, math.floor((i - 1) / cols)
      local b = btn(f, o[2], UDim2.new(c / cols, 2, 0, y + 18 + r * 30), UDim2.new(1 / cols, -4, 0, 26), o[3])
      st[o[1]] = b
      b.MouseButton1Click:Connect(function() set(o[1]) U.applyAll() U.save() end)
    end
    U.rf[#U.rf + 1] = function() for id, b in pairs(st) do setOn(b, get(id)) end end
    return y + 24 + math.ceil(#opts / cols) * 30
  end
  local function listPage(id, names, get, set, fontPrev)
    local f = page(id, true) gridOf(f, UDim2.new(.5, -6, 0, 30))
    local st = {}
    for i, n in ipairs(names) do
      local b = btn(f, n[2], UDim2.new(), UDim2.new(), true) b.LayoutOrder = i st[n[1]] = b
      if fontPrev then b:SetAttribute("fn", n[1]) end
      b.MouseButton1Click:Connect(function() set(n[1]) U.applyAll() U.save() end)
    end
    U.rf[#U.rf + 1] = function() for k, b in pairs(st) do setOn(b, get(k)) end end
  end
  -- settings
  local lg = {} for i, v in ipairs({"English", "Español", "Français", "Deutsch", "Português"}) do lg[i] = {LG[i], v} end
  listPage("language", lg, function(k) return S.lang == k end, function(k) S.lang = k end)
  local fl = {} for i, n in ipairs(FONTS) do fl[i] = {n, n} end
  listPage("font", fl, function(k) return S.font == k end, function(k) S.font = k end, true)
  local pc = page("colors")
  lbl(pc, "theme", 11, UDim2.fromOffset(2, 0), UDim2.fromOffset(300, 16), Enum.TextXAlignment.Left)
  swatch(pc, 20, 150, function(r) S.col = {r[1], r[2], r[3]} U.applyAll() U.save() end)
  hexrow(pc, 178, function(r) S.col = r U.applyAll() U.save() end)
  local ps = page("style")
  local y = sect(ps, 0, "uitype", (function() local o = {} for i, n in ipairs(UTN) do o[i] = {n, n, true} end return o end)(), 3,
    function(k) return S.ut == k end, function(k) local u = UT[k] S.ut, S.round, S.font, S.col, S.bgm = k, u[1], u[2], {u[3][1], u[3][2], u[3][3]}, u[4] end)
  y = sect(ps, y, "corners", {{0, "Sharp", true}, {1, "Round", true}, {2, "Pill", true}}, 3, function(k) return S.round == k end, function(k) S.round = k end)
  sect(ps, y, "size", {{.85, "S", true}, {1, "M", true}, {1.15, "L", true}}, 3, function(k) return math.abs(S.scale - k) < .01 end, function(k) S.scale = k end)
  local pe = page("effects")
  local o = {} for i, n in ipairs(MODEN) do o[i] = {n, n, true} end
  y = sect(pe, 0, "bgs", o, 4, function(k) return S.bgm == k end, function(k) S.bgm = k end)
  sect(pe, y, "click", {{"Pop", "Pop", true}, {"Ripple", "Ripple", true}, {"Both", "Both", true}, {"Off", "Off", true}}, 4, function(k) return S.click == k end, function(k) S.click = k end)
  -- edit: resize
  local pr = page("resize")
  U.edL = lbl(pr, "", 12, UDim2.fromOffset(0, 0), UDim2.fromOffset(356, 22), nil, true)
  local rs = {{"-10%", -.1, 1}, {"+10%", .1, 1}, {"50%", .5}, {"75%", .75}, {"100%", 1}, {"125%", 1.25}, {"150%", 1.5}, {"200%", 2}, {"300%", 3}}
  for i, r in ipairs(rs) do
    local b = btn(pr, r[1], UDim2.fromOffset(((i - 1) % 4) * 89, 28 + math.floor((i - 1) / 4) * 34), UDim2.fromOffset(85, 30), true)
    b.MouseButton1Click:Connect(function()
      local e = U.sel
      if not (e and e.inst) then return U.st("Tap an item in Equipped, then Edit") end
      e.sc = math.clamp(r[3] and ((e.sc or 1) + r[2]) or r[2], .2, 5) U.edAcc(e) U.edRef() U.pv()
    end)
  end
  -- edit: color
  local pcl = page("color")
  swatch(pcl, 0, 120, function(r) local e = U.sel if e and e.inst then e.cl = r U.edAcc(e) U.pv() else U.st("Tap an item in Equipped, then Edit") end end)
  hexrow(pcl, 126, function(r) local e = U.sel if e and e.inst then e.cl = r U.edAcc(e) U.pv() end end)
  local sb = btn(pcl, "solid", UDim2.fromOffset(0, 160), UDim2.new(.5, -2, 0, 28))
  sb.MouseButton1Click:Connect(function() local e = U.sel if e and e.inst and e.cl then e.sd = not e.sd U.edAcc(e) U.pv() end end)
  local ob = btn(pcl, "orig", UDim2.new(.5, 2, 0, 160), UDim2.new(.5, -2, 0, 28))
  ob.MouseButton1Click:Connect(function() local e = U.sel if e and e.inst then e.cl, e.sd, e.sc = nil, nil, nil U.edAcc(e) U.edRef() U.pv() end end)
end
function U.edRef()
  local e = U.sel
  U.edL.Text = e and ((e.name or "item") .. string.format("  -  %.2fx", e.sc or 1)) or "Tap an item in Equipped, then Edit"
end

-- NAVIGATION --------------------------------------------------------
function U.ph()
  local m = U.m
  local k = PG[m].k
  local s = U.sub[m]
  U.bx.PlaceholderText = k == "cat" and (L("search") .. " " .. tostring(s):lower() .. "...") or k == "char" and "skeleton, zombie, robot..." or k == "emo" and L("search") .. " emotes..." or L("cfgname")
  U.gb.Text = L(k == "cfg" and "save" or "search")
  for _, t in ipairs(U.hx or {}) do t.PlaceholderText = "#FF8800" end
end
function U.view()
  local m = U.m
  local k, s = PG[m].k, U.sub[m]
  U.closeP()
  local srY, gy
  if k == "cat" or k == "char" or (k == "emo" and s == "browse") then srY, gy = 94, 124
  elseif k == "cfg" then srY, gy = 64, 94
  elseif k == "emo" or k == "anim" then gy = 94 end
  sr.Visible = srY ~= nil if srY then sr.Position = UDim2.fromOffset(156, srY) end
  grid.Visible = gy ~= nil if gy then grid.Position = UDim2.fromOffset(156, gy) grid.Size = UDim2.fromOffset(356, 314 - gy) end
  hold.Visible = k == "edit" or k == "set"
  for id, f in pairs(U.pg) do f.Visible = hold.Visible and id == s end
  U.bx.Text = "" U.ph()
  if k == "cat" then U.cat() elseif k == "char" then U.char() elseif k == "emo" then U.emo() elseif k == "anim" then U.anims()
  elseif k == "cfg" then U.cfglist() elseif k == "edit" then U.edRef() end
  for _, f in ipairs(U.rf) do f() end
end
function U.go(m, s)
  U.m = m
  if s then U.sub[m] = s end
  for k, b in pairs(U.mb) do setOn(b, k == m) end
  local pg = PG[m]
  U.ss.Visible = pg.subs ~= nil
  if pg.subs then
    U.sb = U.fill(U.ss, pg.subs, function(n)
      if n == "official" then S.off = not S.off U.save() setOn(U.sb.official, S.off) U.view() return end
      U.sub[m] = n
      for q, b in pairs(U.sb) do if q ~= "official" then setOn(b, q == n) end end
      U.view()
    end)
    for q, b in pairs(U.sb) do setOn(b, (q == "official" and S.off) or q == U.sub[m]) end
  end
  U.view()
end
function U.applyAll()
  theme() U.retheme() U.lang() U.fit() U.setMode() U.ph() for _, f in ipairs(U.rf) do f() end
end
function U.run()
  local k = PG[U.m].k
  if k == "cat" then U.cat() elseif k == "char" then U.char() elseif k == "emo" then U.emo() elseif k == "cfg" then U.saveCfg() end
end
U.gb.MouseButton1Click:Connect(U.run)
U.bx.FocusLost:Connect(function(e) if e then U.run() end end)
U.mb = U.fill(U.ms, MAINS, function(n) U.go(n) end)

-- respawn, hotkey, toggle, cleanup, start ---------------------------
U.cn[#U.cn + 1] = lp.CharacterAdded:Connect(function(c)
  c:WaitForChild("Animate", 5) task.wait(1)
  U.rigLbl()
  for k, id in pairs(U.ch) do U.anim(k, id) end
  local old = U.eq U.eq = {}
  for _, e in ipairs(old) do if e.kind == "Part" then U.setPart(e.prop, e.id, e.thumb, e.tag, nil, e.name) end end
  for _, e in ipairs(old) do
    if e.kind ~= "Part" then
      local en = U.equip(e.kind, e.id, e.name)
      if en and en.inst and (e.sc or e.cl) then en.sc, en.cl, en.sd = e.sc, e.cl, e.sd U.edAcc(en) end
    end
  end
  U.refresh()
end)
U.cn[#U.cn + 1] = UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then menu.Visible = not menu.Visible end end)
local tog = Instance.new("TextButton") tog.Size = UDim2.fromOffset(38, 38) tog.Position = UDim2.new(0, 8, 0.5, -19) tog.Text = "A" tog.TextSize = 18 tog.Active = true tog.Draggable = true tog.Parent = gui
crn(tog, 19)
skin(tog, function() tog.BackgroundColor3 = th.m tog.TextColor3 = th.at tog.Font = th.f end)
tog.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
env.AerialCleanup = function() for _, c in ipairs(U.cn) do pcall(function() c:Disconnect() end) end gui:Destroy() end

U.applyAll()
U.go("items")
U.refresh()
if S.auto ~= "" then for _, c in ipairs(cfgs) do if c.name == S.auto then task.delay(2, function() U.loadCfg(c.data) end) break end end end
