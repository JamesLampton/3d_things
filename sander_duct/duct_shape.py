#!/usr/bin/env python

import math

# Generate the points for the base.
def generate_base_verts(radius, length, z, n_points):
	xo = -length/2
	pts = []

	# First generate one of the ends.
	for i in range(n_points//4):
		rads = math.pi+math.pi*i*4/n_points
		pts.append((radius*math.sin(rads)+xo, radius*math.cos(rads), z,))

	for i in range(n_points//4):
		pts.append((i*length*4/n_points+xo, radius, z,))

	for i in range(n_points//4):
		rads = math.pi*i*4/n_points
		pts.append((length+radius*math.sin(rads)+xo, radius*math.cos(rads), z,))

	for i in range(n_points//4):
		pts.append(((n_points//4 - i)*length*4/n_points+xo, -radius, z,))

	return pts

def generate_conn_verts(radius, z, n_points):
	pts = []

	for i in range(n_points):
		rads = 1.25*math.pi+2*math.pi*i/n_points
		pts.append((radius*math.sin(rads), radius*math.cos(rads), z,))

	return pts

def do_main():
	import sys
	print('//', ' '.join(sys.argv))

	sys.argv.pop(0)

	ah_width_mm = int(sys.argv.pop(0))
	ah_end_radius_mm = ah_width_mm/2
	ah_length_mm = int(sys.argv.pop(0))
	ah_length_mm -= ah_width_mm
	conn_d_mm = float(sys.argv.pop(0))
	part_height = int(sys.argv.pop(0))

	face_pts = 40

	base_pts = generate_base_verts(ah_end_radius_mm, ah_length_mm, 0, 4*face_pts)
	conn_pts = generate_conn_verts(conn_d_mm/2, part_height, face_pts*4)

	print('module funnel_pts_%d_%d_%d_%d() {' % (ah_width_mm, ah_length_mm, conn_d_mm, part_height))

	print('base_pts = [')
	for i, p in enumerate(base_pts):
		print('\t[%f, %f], // %d' % (p[0], p[1], i))
	print('];')
	print('conn_pts = [')
	for i, p in enumerate(conn_pts):
		print('\t[%f, %f], // %d' % (p[0], p[1], i))
	print('];')

	print('funnel_pts = [')
	for i, p in enumerate(base_pts + conn_pts):
		#print('\t[%f, %f], // %d' % (p[0], p[1], i))
		print('\t[%f, %f, %f], // %d' % (p[0], p[1], p[2], i))
	print('];')

	print('funnel_faces = [')
	print('\t[%s],' % ','.join(map(str, range(len(base_pts)))))
	for i in range(len(base_pts)+1):
		conn_i = len(base_pts) + (i % len(base_pts))
		conn_i1 = len(base_pts) + ((i+1) % len(base_pts))
		print('\t[%d, %d, %d, %d],' % (i%len(base_pts), (i+1)%len(base_pts), conn_i1, conn_i))
	print('\t[%s]' % ','.join(map(str, range(len(base_pts), len(base_pts) + len(conn_pts)))))
	print('];')

	print('hull(){polyhedron(funnel_pts, faces=funnel_faces);}}')

if __name__ == '__main__': do_main()

