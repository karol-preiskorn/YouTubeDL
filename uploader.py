import os
import sys
import subprocess
import random
import string

file_desc_length = 10

def get_desc():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(file_desc_length))


def upload( dirname, filename ):
    command = "youtube-upload --privacy=private --title='{0}' '{1}/{2}'".format(get_desc(),dirname,filename)
    print "calling subproccess with the following command", command
    process = subprocess.Popen(command, shell=True,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        stdin=subprocess.PIPE)
    print "process complete"
    output = process.communicate()[0]
    print "outputu is", output


def find_files(path, ext):
    for dirname, dirnames, filenames in os.walk(path):
        for filename in filenames:
            if filename.endswith(ext):
                print("calling upload with the following file", os.path.join(dirname, filename))
                upload( dirname, filename)




if __name__ == '__main__':
    if sys.argv < 2:
        print "must supply a dir path and file extension"
        sys.exit()
    find_files(sys.argv[1], sys.argv[2])
