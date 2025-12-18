# Snapshot Manager scripts and tools

Small scripts and tools used in ``snapm`` and ``boom-boot`` development and
release preparation.

* **docify.py** - convert command output into MD/groff example notation.
* **git-branchdiff** - shortcut for ``git diff main..HEAD``
* **git-branchlog** - shortcut for ``git log main..HEAD``
* **git-fix** - shortcut for ``git commit --fixup=COMMIT``
* **git-rebasquash** - shortcut for ``git rebase -i --autosquash $BRANCH``
* **git-resolves** - fugly shell script to generate sorted
  "{Resolves,Related}: #XXX" tags from git commit logs.
* **git-userstats** - shortcut for ``git shortlog -ns @~``
* **mkrelease.sh** - Update snapm/boom-boot style release metadata
* **quickmock.sh** - Run a quick mock build from HEAD using the in-tree spec file.

These files are released under the Apache-2.0 license.
