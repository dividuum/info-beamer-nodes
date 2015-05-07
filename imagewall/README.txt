Scrolling Image Wall
====================

Copy jpg or png files into this directory. To avoid
jittering make sure that you scale the images down
so they can be loaded quickly.

While images are loaded in the background the final
texture transfer to the GPU has to happen in the
foreground. If images are big this might be noticable.
So just use smaller images :-)

You can add and remove images while the node is
running.

There are some settings in the first few lines of
node.lua that you can change.
