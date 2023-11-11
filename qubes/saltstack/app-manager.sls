{% set user = "user" %}
{% set app_dirpath = "/home/user/Apps" %}
{% set am_vcpus = 10 %}
{% set dev_name = "dev" %}

{% set emacs_dirpath = "%s/emacs" | format(app_dirpath) %}
{% set emacs_build_path = "%s/build" | format(emacs_dirpath) %}
{% set emacs_prefix = "/usr/local" %}
{% set emacs_compiled_exec_path = "%s/src/emacs" | format(emacs_build_path) %}
{% set emacs_install_path = "%s/install" | format(emacs_build_path) %}
{% set emacs_library_path = "%s%s/solib" | format(emacs_install_path, emacs_prefix) %}
{% set emacs_packaged_filename = "portable-emacs.tar.gz" %}

{{ app_dirpath }}:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}

# begin Emacs
emacs-cloned:
  git.cloned:
    - name: git://git.sv.gnu.org/emacs.git
    - target: {{ emacs_dirpath }}
    - branch: emacs-29.1
    - user: {{ user }}

emacs-autogen:
  cmd.run:
    - runas: {{ user }}
    - cwd: {{ emacs_dirpath }}
    - creates: {{ emacs_dirpath }}/configure
    - name: ./autogen.sh

{{ emacs_build_path }}:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}

emacs-configured:
  cmd.run:
    - runas: {{ user }}
    - cwd: {{ emacs_build_path }}
    - creates: {{ emacs_build_path }}/Makefile
    # on Qubes (as it's X-only):
    # no '--with-pgtk' and add some X packages
    - name: >
        ../configure
        --prefix={{ emacs_prefix }}
        --with-json
        --with-native-compilation=aot
        --with-sound=alsa
        --with-mailutils
        --with-xwidgets
        --with-x-toolkit=gtk3
        --with-imagemagick
        --with-tree-sitter
        --with-file-notification=inotify
        'CFLAGS=-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wall'
        'CPPFLAGS=-Wdate-time -D_FORTIFY_SOURCE=2'
        'LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro'

emacs-compiled:
  cmd.run:
    - runas: {{ user }}
    - cwd: {{ emacs_build_path }}
    - creates: {{ emacs_compiled_exec_path }}
    - name: make -j{{ am_vcpus }}
    
{{ emacs_install_path }}:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}

emacs-installed-to-path:
  cmd.run:
    - runas: {{ user }}
    - cwd: {{ emacs_build_path }}
    - creates: {{ emacs_install_path }}{{ emacs_prefix }}/bin/emacs
    - name: make DESTDIR={{ emacs_install_path }} install

{{ emacs_library_path }}:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}

emacs-libs-prepared:
  cmd.run:
    - runas: {{ user }}
    - cwd: {{ emacs_build_path }}
    # gets the list of all libraries of Emacs
    # the 'tail' call excludes 'linux-vdso.so'
    - name: >
        cp $(ldd {{ emacs_compiled_exec_path }}
        | tail -n +2
        | awk '{print $3}'
        | paste -sd' '
        )
        {{ emacs_library_path }}

emacs-packaged:
  cmd.run:
    - runas: {{ user }}
    - cwd: {{ emacs_build_path }}
    - creates: {{ emacs_build_path }}/{{ emacs_packaged_filename }}
    - name: >
        tar -chzf {{ emacs_packaged_filename }}
        -C {{ emacs_install_path }}{{ emacs_prefix }} .

emacs-copied-to-dev:
  cmd.run:
    - runas: {{ user }}
    - name: qvm-copy-to-vm {{ dev_name }} {{ emacs_build_path }}/{{ emacs_packaged_filename }}
# end Emacs
