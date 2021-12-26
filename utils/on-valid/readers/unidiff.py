# -*- coding: utf-8 -*-
# vim:set shiftwidth=4 tabstop=4 expandtab textwidth=80:

import os,sys
from ._Readers import readers

class unidiff(readers):

    def __init__(self, **config):
        uXml = os.path.join(config['datpath'], 'unidiff.xml')
        readers.__init__(self, uXml, config['verbose'])
        self._componentName = 'unidiff'
        self.used = []
        self.unknown = list()

        self.nameList = []
        print('Compiling unidiff ...',end='      ')
        for diff in self.xmlData.findall('unidiff'):
            self.nameList.append(diff.attrib['name'])
        self.techList = []
        for diff in self.xmlData.findall('unidiff/tech/add'):
            self.techList.append(diff.text)
        self.assetList = []
        for diff in self.xmlData.findall('unidiff/system/asset'):
            self.assetList.append(diff.attrib['name'])
        print("DONE")

    def find(self, name):
        """
        return True if name is found in unidiff.xml
        And if so, add name in the used list.
        """
        if name not in self.nameList:
            return False
        if name not in self.used:
            self.used.append(name)
        return True

    def findTech(self, name):
        return name in self.techList

    def findAsset(self, name):
        return name in self.assetList
