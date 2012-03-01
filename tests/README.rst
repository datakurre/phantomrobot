::
    python bootstrap.py
    bin/buildout -c buildout-linux.cfg
    source bin/activate
    make -C ..

    node ../phantomrobot.js

    bin/pybot example-suite.txt
