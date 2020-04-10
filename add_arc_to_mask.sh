#!/bin/bash -i
#
# use -i flag here to use aliases like fit2d
#
# e.g.
# add_arc_to_mask s7476_45_00001r1_00001.cbf mask.msk mask_out.msk 479 340 20 335 479 330 1

# fit2d alias must be set, too
# path to Fit2D macro-files
path_to_mac='/home/msmile/Seafile/MartinS/bash/'


# 10 input args are required
if (( "$#" != 10 )); then
	echo "10 input arguments needed"
	echo ""
	echo "Usage:"
	echo ""
	echo "add_arc_to_mask <imagefile> <maskfile_in.msk> <maskfile_out.msk> <p1_x> <p1_y> <p2_x> <p2_y> <p3_x> <p3_y> <linethickness>"
	echo ""
	exit
fi

# dummy image
if [ ! -f $1 ] ; then
	echo "Error: image file not found. Exit."
	exit
fi

# mask
if [ ! -f $2 ] ; then
	echo "Error: input mask file not found. Exit."
	exit
fi

# call fit2d macro
# for debugging
#echo "$(fit2d -key -dim1024x1024 -svar#FILE_IN=$1 -svar#MASK_IN=$2 -svar#MASK_OUT=$3 -fvar#P1X=$4 -fvar#P1Y=$5 -fvar#P2X=$6 -fvar#P2Y=$7 -fvar#P3X=$8 -fvar#P3Y=$9 -fvar#LINETHICKNESS=${10} -mac${path_to_mac}fit2d_add_arc_to_mask.mac)"
$(fit2d -key -dim1024x1024 -svar#FILE_IN=$1 -svar#MASK_IN=$2 -svar#MASK_OUT=$3 -fvar#P1X=$4 -fvar#P1Y=$5 -fvar#P2X=$6 -fvar#P2Y=$7 -fvar#P3X=$8 -fvar#P3Y=$9 -fvar#LINETHICKNESS=${10} -mac${path_to_mac}fit2d_add_arc_to_mask.mac)

