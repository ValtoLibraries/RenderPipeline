

class RenderPass:

    """ Abstract class which defines a RenderPass. This is used by the
    RenderPassMatcher. Each pass has to derive from this class """

    def __init__(self):
        pass

    def getID(self):
        raise NotImplementedError()

    def getRequiredInputs(self):
        return {}

    def setShaders(self):
        pass

    def create(self):
        raise NotImplementedError()

    def getOutputNames(self):
        return []

    def getDefines(self):
        return {}

    def getOutputs(self):
        return {}

    def preRenderUpdate(self):
        pass

    def setShaderInput(self, name, value, *args):
        self.target.setShaderInput(name, value, *args)

    def __repr__(self):
        return "#" + self.getID()