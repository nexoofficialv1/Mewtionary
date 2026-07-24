"""
Mewtionary 3D Teacher v2.0 Blender blockout generator.

Run inside Blender:
    Scripting workspace -> Open -> Run Script

It creates:
- Original stylized adult male teacher
- Separate rigid body parts
- Armature with named bones
- Book, pointer, chalk
- Basic pose actions
- GLB and FBX export

This is a production blockout, not the final sculpt.
"""

import bpy
import math
from mathutils import Vector

# Reset
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

def mat(name, rgba, metallic=0.0, roughness=0.5):
    m = bpy.data.materials.new(name)
    m.diffuse_color = rgba
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = rgba
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    return m

SKIN = mat("Skin", (0.96, 0.58, 0.40, 1), roughness=.55)
HAIR = mat("Hair", (0.16, 0.045, 0.025, 1), roughness=.35)
HAIR_LIGHT = mat("HairHighlight", (0.34, 0.11, 0.06, 1), roughness=.4)
SHIRT = mat("Shirt", (1.0, .96, .88, 1), roughness=.7)
VEST = mat("Vest", (.18, .17, .15, 1), roughness=.6)
PANTS = mat("Trousers", (.45, .29, .20, 1), roughness=.7)
SHOE = mat("Shoes", (.19, .05, .025, 1), roughness=.38)
TIE = mat("Tie", (.02, .22, .38, 1), roughness=.4)
WHITE = mat("EyeWhite", (1, 1, 1, 1), roughness=.25)
IRIS = mat("Iris", (.25, .08, .03, 1), roughness=.25)
BLACK = mat("Black", (.01, .008, .006, 1), roughness=.35)
BOOK = mat("Book", (.38, .035, .055, 1), roughness=.5)
PAPER = mat("Paper", (.95, .84, .64, 1), roughness=.8)

parts = {}

def uv(name, loc, scale, material):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=40, ring_count=24, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material)
    parts[name] = o
    return o

def cube(name, loc, scale, material, bevel=.08):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = o.modifiers.new("SoftEdges", "BEVEL")
        mod.width = bevel
        mod.segments = 3
    o.data.materials.append(material)
    parts[name] = o
    return o

def capsule(name, loc, radius, depth, material):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=20, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = (radius, depth / 2, radius)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material)
    parts[name] = o
    return o

# Body
cube("Torso_Shirt", (0, 0, 1.65), (.52, .30, .63), SHIRT, .16)
cube("Vest_Left", (-.16, -.32, 1.66), (.25, .07, .58), VEST, .06)
cube("Vest_Right", (.16, -.32, 1.66), (.25, .07, .58), VEST, .06)
cube("Tie", (0, -.40, 1.72), (.09, .04, .36), TIE, .03)

# Legs/shoes
capsule("Leg_L", (-.21, 0, .82), .18, 1.15, PANTS)
capsule("Leg_R", (.21, 0, .82), .18, 1.15, PANTS)
cube("Foot_L", (-.21, -.13, .18), (.25, .39, .14), SHOE, .10)
cube("Foot_R", (.21, -.13, .18), (.25, .39, .14), SHOE, .10)

# Arms
capsule("UpperArm_L", (-.64, 0, 1.73), .14, .62, SHIRT)
capsule("Forearm_L", (-.72, 0, 1.20), .12, .58, SKIN)
uv("Hand_L", (-.72, 0, .86), (.16, .13, .18), SKIN)
capsule("UpperArm_R", (.64, 0, 1.73), .14, .62, SHIRT)
capsule("Forearm_R", (.72, 0, 1.20), .12, .58, SKIN)
uv("Hand_R", (.72, 0, .86), (.16, .13, .18), SKIN)

# Neck/head
capsule("Neck", (0, 0, 2.33), .17, .35, SKIN)
uv("Head", (0, 0, 2.78), (.61, .52, .69), SKIN)
uv("Ear_L", (-.59, 0, 2.76), (.14, .10, .23), SKIN)
uv("Ear_R", (.59, 0, 2.76), (.14, .10, .23), SKIN)
uv("Hair_Top", (0, .02, 3.23), (.66, .49, .28), HAIR)
uv("Hair_Sweep", (-.16, -.18, 3.31), (.48, .25, .17), HAIR_LIGHT)
uv("Beard", (0, -.43, 2.52), (.49, .20, .34), HAIR)
cube("Moustache_L", (-.13, -.58, 2.64), (.18, .04, .05), HAIR, .03)
cube("Moustache_R", (.13, -.58, 2.64), (.18, .04, .05), HAIR, .03)
uv("Nose", (0, -.58, 2.78), (.11, .08, .12), SKIN)

# Eyes/pupils
uv("Eye_L", (-.21, -.51, 2.91), (.17, .07, .22), WHITE)
uv("Eye_R", (.21, -.51, 2.91), (.17, .07, .22), WHITE)
uv("Pupil_L", (-.21, -.575, 2.91), (.075, .035, .10), IRIS)
uv("Pupil_R", (.21, -.575, 2.91), (.075, .035, .10), IRIS)
cube("Brow_L", (-.21, -.54, 3.17), (.20, .035, .04), HAIR, .025)
cube("Brow_R", (.21, -.54, 3.17), (.20, .035, .04), HAIR, .025)

# Glasses using torus
for x, suffix in [(-.21, "L"), (.21, "R")]:
    bpy.ops.mesh.primitive_torus_add(
        major_radius=.20, minor_radius=.018,
        major_segments=32, minor_segments=8,
        location=(x, -.61, 2.91),
        rotation=(math.radians(90), 0, 0)
    )
    g = bpy.context.object
    g.name = f"Glasses_{suffix}"
    g.data.materials.append(BLACK)
    parts[g.name] = g
cube("Glasses_Bridge", (0, -.61, 2.91), (.06, .02, .02), BLACK, .015)

# Mouth shapes as separate objects
cube("Mouth_Rest", (0, -.615, 2.54), (.16, .025, .025), BLACK, .02)
uv("Mouth_A", (0, -.62, 2.54), (.14, .035, .10), BOOK)
cube("Mouth_E", (0, -.62, 2.54), (.18, .035, .055), BOOK, .04)
uv("Mouth_O", (0, -.62, 2.54), (.09, .035, .13), BOOK)
cube("Mouth_MBP", (0, -.62, 2.54), (.16, .025, .025), BLACK, .02)
cube("Mouth_FV", (0, -.62, 2.54), (.16, .025, .045), BOOK, .02)
uv("Mouth_LRTDN", (0, -.62, 2.54), (.11, .035, .08), BOOK)
for n in ["Mouth_A","Mouth_E","Mouth_O","Mouth_MBP","Mouth_FV","Mouth_LRTDN"]:
    parts[n].hide_viewport = True
    parts[n].hide_render = True

# Props
cube("Book_Closed", (-.78, -.08, 1.02), (.33, .10, .47), BOOK, .06)
cube("Book_Page", (-.67, -.19, 1.02), (.04, .02, .42), PAPER, .01)
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=.025, depth=1.15, location=(.78, 0, 1.28))
pointer = bpy.context.object
pointer.name = "Pointer"
pointer.data.materials.append(HAIR)
parts["Pointer"] = pointer
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=.035, depth=.20, location=(.78, 0, .92))
chalk = bpy.context.object
chalk.name = "Chalk"
chalk.data.materials.append(WHITE)
parts["Chalk"] = chalk

# Armature
bpy.ops.object.armature_add(enter_editmode=True, location=(0,0,0))
arm = bpy.context.object
arm.name = "MewtionaryTeacher_Rig"
arm_data = arm.data
base = arm_data.edit_bones[0]
base.name = "root"
base.head = (0,0,0)
base.tail = (0,0,.4)

def bone(name, head, tail, parent):
    b = arm_data.edit_bones.new(name)
    b.head = head
    b.tail = tail
    b.parent = arm_data.edit_bones[parent]
    return b

bone("spine", (0,0,.4), (0,0,2.25), "root")
bone("head", (0,0,2.25), (0,0,3.15), "spine")
bone("upper_arm.L", (-.45,0,1.95), (-.68,0,1.55), "spine")
bone("forearm.L", (-.68,0,1.55), (-.72,0,.98), "upper_arm.L")
bone("hand.L", (-.72,0,.98), (-.72,0,.78), "forearm.L")
bone("upper_arm.R", (.45,0,1.95), (.68,0,1.55), "spine")
bone("forearm.R", (.68,0,1.55), (.72,0,.98), "upper_arm.R")
bone("hand.R", (.72,0,.98), (.72,0,.78), "forearm.R")
bone("thigh.L", (-.21,0,1.25), (-.21,0,.65), "root")
bone("shin.L", (-.21,0,.65), (-.21,0,.18), "thigh.L")
bone("foot.L", (-.21,0,.18), (-.21,-.32,.18), "shin.L")
bone("thigh.R", (.21,0,1.25), (.21,0,.65), "root")
bone("shin.R", (.21,0,.65), (.21,0,.18), "thigh.R")
bone("foot.R", (.21,0,.18), (.21,-.32,.18), "shin.R")
bpy.ops.object.mode_set(mode='OBJECT')

# Rigid parent map
parent_map = {
    "Torso_Shirt":"spine","Vest_Left":"spine","Vest_Right":"spine","Tie":"spine","Neck":"spine",
    "Head":"head","Ear_L":"head","Ear_R":"head","Hair_Top":"head","Hair_Sweep":"head","Beard":"head",
    "Moustache_L":"head","Moustache_R":"head","Nose":"head","Eye_L":"head","Eye_R":"head",
    "Pupil_L":"head","Pupil_R":"head","Brow_L":"head","Brow_R":"head","Glasses_L":"head",
    "Glasses_R":"head","Glasses_Bridge":"head","Mouth_Rest":"head","Mouth_A":"head","Mouth_E":"head",
    "Mouth_O":"head","Mouth_MBP":"head","Mouth_FV":"head","Mouth_LRTDN":"head",
    "UpperArm_L":"upper_arm.L","Forearm_L":"forearm.L","Hand_L":"hand.L","Book_Closed":"hand.L","Book_Page":"hand.L",
    "UpperArm_R":"upper_arm.R","Forearm_R":"forearm.R","Hand_R":"hand.R","Pointer":"hand.R","Chalk":"hand.R",
    "Leg_L":"thigh.L","Foot_L":"foot.L","Leg_R":"thigh.R","Foot_R":"foot.R",
}
for obj_name, bone_name in parent_map.items():
    obj = parts.get(obj_name)
    if not obj:
        continue
    obj.parent = arm
    obj.parent_type = 'BONE'
    obj.parent_bone = bone_name
    obj.matrix_parent_inverse = arm.matrix_world.inverted()

# Actions
def make_action(name, frames):
    action = bpy.data.actions.new(name)
    arm.animation_data_create()
    arm.animation_data.action = action
    for frame, poses in frames.items():
        for bone_name, rot in poses.items():
            pb = arm.pose.bones.get(bone_name)
            if pb is None:
                continue
            pb.rotation_mode = 'XYZ'
            pb.rotation_euler = tuple(math.radians(v) for v in rot)
            pb.keyframe_insert("rotation_euler", frame=frame)
    action.use_fake_user = True

make_action("Welcome", {
    1: {"upper_arm.R":(0,0,-45),"forearm.R":(0,0,-45)},
    15:{"upper_arm.R":(0,0,-65),"forearm.R":(0,0,-30)},
    30:{"upper_arm.R":(0,0,-45),"forearm.R":(0,0,-45)},
})
make_action("Praise", {
    1: {"upper_arm.L":(0,0,0),"upper_arm.R":(0,0,0)},
    12:{"upper_arm.L":(0,0,60),"forearm.L":(0,0,35),"upper_arm.R":(0,0,-60),"forearm.R":(0,0,-35)},
    24:{"upper_arm.L":(0,0,0),"upper_arm.R":(0,0,0)},
})
make_action("Point", {
    1: {"upper_arm.R":(0,0,0)},
    15:{"upper_arm.R":(-15,15,-70),"forearm.R":(0,0,-25)},
    30:{"upper_arm.R":(-15,15,-70),"forearm.R":(0,0,-25)},
})
make_action("Dance", {
    1: {"upper_arm.L":(0,0,45),"upper_arm.R":(0,0,-45),"thigh.L":(12,0,0),"thigh.R":(-12,0,0)},
    12:{"upper_arm.L":(0,0,70),"upper_arm.R":(0,0,-20),"thigh.L":(-12,0,0),"thigh.R":(12,0,0)},
    24:{"upper_arm.L":(0,0,45),"upper_arm.R":(0,0,-45),"thigh.L":(12,0,0),"thigh.R":(-12,0,0)},
})

# Save and export
bpy.context.scene.render.engine = 'BLENDER_EEVEE_NEXT'
bpy.context.scene.world.color = (0.72, 0.88, 0.92)
bpy.ops.wm.save_as_mainfile(filepath="//MewtionaryTeacher_Blockout_v2.blend")
bpy.ops.export_scene.gltf(filepath="//MewtionaryTeacher_Blockout_v2.glb", export_format='GLB')
bpy.ops.export_scene.fbx(filepath="//MewtionaryTeacher_Blockout_v2.fbx", add_leaf_bones=False)
print("Mewtionary teacher blockout generated and exported.")
