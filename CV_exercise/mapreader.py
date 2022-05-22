#!/usr/bin/env python3
# This is template for your program, for you to expand with all the correct
# functionality.

from email.mime import image
import sys, cv2

#-------------------------------------------------------------------------------
# Main program.

# Ensure we were invoked with a single argument.

if len (sys.argv) != 2:
    print ("Usage: %s <image-file>" % sys.argv[0], file=sys.stderr)
    exit (1)


# for loop to run any image from the develop folder
for fn in sys.argv[1:]:
    image = cv2.imread(fn, cv2.IMREAD_UNCHANGED)

    # WRITE YOUR CODE IN HERE
    # TO RUN THE PROGRAM TYPE IN THE TERMINAL python3 mapreader.py develop/develop-001.jpg



    





print ("The filename to work on is %s." % sys.argv[1])
xpos = 0.5
ypos = 0.5
hdg = 45.1

# Output the position and bearing in the form required by the test harness.
print ("POSITION %.3f %.3f" % (xpos, ypos))
print ("BEARING %.1f" % hdg)

#-------------------------------------------------------------------------------

