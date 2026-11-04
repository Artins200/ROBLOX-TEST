#!/usr/bin/env python3
"""Build a self-contained Roblox XML place from the repository's scripts."""
from pathlib import Path
import xml.etree.ElementTree as ET

root_dir = Path(__file__).resolve().parent.parent
root = ET.Element('roblox', {'version': '4'})
ET.SubElement(root, 'External').text = 'null'
ET.SubElement(root, 'External').text = 'nil'
serial = 0

def item(parent, class_name, name):
    global serial
    serial += 1
    obj = ET.SubElement(parent, 'Item', {'class': class_name, 'referent': f'RBX{serial}'})
    props = ET.SubElement(obj, 'Properties')
    ET.SubElement(props, 'string', {'name': 'Name'}).text = name
    return obj, props

def vector(props, prop_name, x, y, z):
    v = ET.SubElement(props, 'Vector3', {'name': prop_name})
    for key, value in zip(('X', 'Y', 'Z'), (x, y, z)):
        ET.SubElement(v, key).text = str(value)

def position(props, x, y, z):
    cf = ET.SubElement(props, 'CoordinateFrame', {'name': 'CFrame'})
    for key, value in [('X', x), ('Y', y), ('Z', z), ('R00', 1), ('R01', 0), ('R02', 0),
                       ('R10', 0), ('R11', 1), ('R12', 0), ('R20', 0), ('R21', 0), ('R22', 1)]:
        ET.SubElement(cf, key).text = str(value)

def boolean(props, name, value):
    ET.SubElement(props, 'bool', {'name': name}).text = str(value).lower()

workspace, _ = item(root, 'Workspace', 'Workspace')
base, props = item(workspace, 'Part', 'Baseplate')
vector(props, 'size', 160, 2, 160)
position(props, 0, -1, 0)
boolean(props, 'Anchored', True)
spawn, props = item(workspace, 'SpawnLocation', 'SpawnLocation')
vector(props, 'size', 8, 1, 8)
position(props, 0, 0.5, 0)
boolean(props, 'Anchored', True)
boolean(props, 'Neutral', True)

server, _ = item(root, 'ServerScriptService', 'ServerScriptService')
script, props = item(server, 'Script', 'AnimalHatchery')
ET.SubElement(props, 'ProtectedString', {'name': 'Source'}).text = (root_dir / 'AnimalHatchery.server.lua').read_text(encoding='utf-8')
boolean(props, 'Disabled', False)

starter, _ = item(root, 'StarterPlayer', 'StarterPlayer')
player_scripts, _ = item(starter, 'StarterPlayerScripts', 'StarterPlayerScripts')
script, props = item(player_scripts, 'LocalScript', 'HatcheryUI')
ET.SubElement(props, 'ProtectedString', {'name': 'Source'}).text = (root_dir / 'HatcheryUI.client.lua').read_text(encoding='utf-8')
boolean(props, 'Disabled', False)

ET.indent(root, space='  ')
ET.ElementTree(root).write(root_dir / 'PetHatchery.rbxlx', encoding='utf-8', xml_declaration=True)
