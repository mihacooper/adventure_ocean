__author__ = 'mihacooper'

import importlib, os, re
from kernel.helpers import *

models = []
if len(models) == 0:
    Info("Start loading models...")
    for file in os.listdir("server"):
        gname = re.match("^mod_(\w+)\.py$", file)
        if gname:
            name = "server.mod_" + gname.group(1)
            loader = importlib.import_module(name)
            Info("Model %s was loaded" % name)
            model = loader.Initialize()
            models.append(model)
    Info("Model loading finished")
