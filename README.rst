===========================================================================
Exemple of a generic pgsql db deployment with salt/makina-states
===========================================================================

.. contents::

USE/Install With makina-states
-------------------------------
- Iniatilise on the target platform the project if it is not already done::

    salt mc_project.init_project name=<foo>

- Keep under the hood both remotes (pillar & project).

- Clone the project pillar remote inside your project top directory

- Add/Relace your salt deployment code inside **.salt** inside your repository.

- Add the project remote

    - replace remotenickname with a sensible name (eg: prod)::
    - replace the_project_remote_given_in_init with the real url

    - Run the following commands::

        git remote add <remotenickname>  <the_project_remote_given_in_init>
        git fetch --all

- Each time you need to deploy from your computer, run::

    cd pillar
    git push [--force] <remotenickname> <yourlocalbranch(eg: master,prod,whatever)>:master
    cd ..
    git push [--force] <remotenickname> <yourlocalbranch(eg: master,prod,whatever)>:master

- Notes:

    - The distant branch is always *master**
    - If you force the push, the local working copy of the remote deployed site
      will be resetted to the TIP changeset your are pushing.

- If you want to install locally on the remote computer, or test it locally and
  do not want to run the full deployement procedure, when you are on a shell
  (connected via ssh on the remote computer or locally on your box), run::

      salt mc_project.deploy only=install,fixperms

- You can also run just specific step(s)::

      salt mc_project.deploy only=install,fixperms only_steps=000_whatever
      salt mc_project.deploy only=install,fixperms only_steps=000_whatever,001_else

- If you want to commit in prod and then push back from the remote computer, remember
  to push on the right branch, eg::

    git remote add github https://github.com/orga/repo.git
    git fetch --all
    git push github master:prod


Exemple pillar
--------------
::

  makina-projects.pgsql:
   data:
    backup_disabled: false
    pgver: 9.6
    mail: sysadmin@foo.com
    pg_optim:
      #./pgtune/pgtune -i /etc/postgresql/9.5/main/postgresql.conf -M $((15842612*1024))
      - default_statistics_target = 100
      - maintenance_work_mem = 960MB
      - checkpoint_completion_target = 0.9
      - effective_cache_size = 11GB
      - work_mem = 72MB
      - shared_buffers = 3840MB
    sysctls:
      - kernel.shmall: 4026531840
      - kernel.shmmax: 16106127360
    databases:
      - x:
          password: "x"
          user: x
