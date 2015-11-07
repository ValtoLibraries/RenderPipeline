



from panda3d.core import *
from random import random


load_prc_file("../../Config/configuration.prc")
load_prc_file_data("", "show-frame-rate-meter #t")
load_prc_file_data("", "gl-debug #t")
# load_prc_file_data("", "notify-level-glgsg debug")

import direct.directbase.DirectStart

import sys
sys.path.insert(0, "../../")

from Native.RSNative import StaticGeometryHandler, SGNode, SGRenderNode
from Code.Util.MovementController import MovementController


controller = MovementController(base)
controller.set_initial_position(Vec3(10, 0, 10), Vec3(0))
controller.setup()



shader = Shader.load(Shader.SL_GLSL, "render_vtx.glsl", "render_frag.glsl")


# This is usually done by the pipeline
handler = StaticGeometryHandler()


# Load model
model_dataset = handler.load_dataset("model.rpsg")

for x in xrange(1):
    for y in xrange(1):

        node = SGNode("test", handler, model_dataset)
        np = render.attach_new_node(node)

        np.set_scale(0.4)
        np.set_pos( (x-4), (y-4), 0)



base.camLens.setNearFar(0.01, 1000.0)
base.camLens.setFov(90)

# np.set_scale(0.5)
collect_shader = Shader.load_compute(Shader.SL_GLSL, "collect_objects.compute.glsl")


finish_node = SGRenderNode(handler, collect_shader)
finish_np = render.attach_new_node(finish_node)
finish_np.set_shader(shader, 1000)
# finish_np.set_two_sided(True)

def update(task):
    cpos = base.camera.getPos(render)
    cdir = base.camera.getQuat(render).getForward()
    finish_np.set_shader_input("cameraPosition", cpos)
    finish_np.set_shader_input("cameraDirection", cdir)

    return task.cont

base.addTask(update, "update")

base.run()

sys.exit(0)




