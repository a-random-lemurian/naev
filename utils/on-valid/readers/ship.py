# -*- coding: utf-8 -*-
# vim:set shiftwidth=4 tabstop=4 expandtab textwidth=80:

import os,sys
from glob import glob
from ._Readers import readers

class ship(readers):
    def __init__(self, **config):
        shipsXml = glob(os.path.join(config['datpath'], 'ships/*.xml'))
        readers.__init__(self, shipsXml, config['verbose'])
        self._componentName = 'ship'
        self._tech = config['tech']
        self.used = list()
        self.unknown = []

        self.nameList = []
        self.missingTech = []
        self.missingLua = list()
        self.missionInTech = []
        print('Compiling ship list ...',end='       ')
        try:
            for ship in self.xmlData:
                ship = ship.getroot()
                name = ship.attrib['name']
                self.nameList.append(name)
                if ship.find('mission') is None:
                    if not self._tech.findItem(name):
                        self.missingTech.append(name)
                    else:
                        self.used.append(name)
                else:
                    self.missingLua.append(name)
                    if self._tech.findItem(name):
                        self.missionInTech.append(name)
        except Exception as e:
            print('FAILED')
            raise e
        else:
            print("DONE")

        self.missingLua.sort()

    def find(self, name):
        if name not in self.nameList:
            return False
        if name in self.missingLua:
            self.missingLua.remove(name)
        if name not in self.used:
            self.used.append(name)
        return True

    def showMissingTech(self):
        if len(self.missingTech) > 0 or len(self.missingLua) > 0:
            print('\nship.xml unused items:')

        # Player-buyable ships.
        if len(self.missingTech) > 0:
            for item in self.missingTech:
                print("Warning: item ''{0}`` is not found in tech.xml".format(item))

        # Mission-specific ships.
        if len(self.missingLua) > 0:
            for item in self.missingLua:
                print("Warning: mission item ''{0}`` is not found in lua files".format(item))

        # Mission-specific ships should never be in tech.xml
        if len(self.missionInTech) > 0:
            for item in self.missionInTech:
                print("Warning: mission item ''{0}`` was found in tech.xml".format(item))
