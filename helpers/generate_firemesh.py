#!/usr/bin/env python3

sub = 128

last_index = 1
vertices = []
known_vertices = {}
quads = []
width = sub * 2 + 1

def get_vert(x, y, z):
	pos = (x, y, z)
	global known_vertices
	global vertices
	if pos not in known_vertices:
		global last_index
		known_vertices[pos] = last_index
		vertices.append(pos)
		last_index += 1
	return known_vertices[pos]


for xi in range(-4, 5):
	x = xi / 5
	quads.append((get_vert(x, -1, -1), get_vert(x, 1, -1), get_vert(x, -1, 1), get_vert(x, 1, 1)))
	quads.append((get_vert(x, -1, -1), get_vert(x, -1, 1), get_vert(x, 1, -1), get_vert(x, 1, 1)))
for zi in range(-4, 5):
	z = zi / 5
	quads.append((get_vert(-1, -1, z), get_vert(-1, 1, z), get_vert(1, -1, z), get_vert(1, 1, z)))
	quads.append((get_vert(-1, -1, z), get_vert(1, -1, z), get_vert(-1, 1, z), get_vert(1, 1, z)))

for (x, y, z) in vertices:
	print("v", x, y, z)

for (x0y0, x1y0, x0y1, x1y1) in quads:
	print("f", x0y0, x1y0, x0y1)
	print("f", x0y1, x1y0, x1y1)
