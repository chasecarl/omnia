{% set dev_name = "dev" %}
{% set app_manager_name = "app-manager" %}
{% set user = "user" %}
{% set emacs_packaged_filename = "portable-emacs.tar.gz" %}
{% set emacs_library_path = "/usr/local/solib" %}

git:
  pkg.installed

# assumes app_manager already run
emacs-installed:
  archive.extracted:
    - name: /usr/local
    - source: "/home/{{ user }}/QubesIncoming/{{ app_manager_name }}\
        /{{ emacs_packaged_filename }}"
    - user: {{ user }}
    - group: {{ user }}

emacs-desktop-configured:
  file.replace:
    - name: /usr/local/share/applications/emacs.desktop
    - pattern: "^(Exec=)(emacs.*)$"
    - repl: '\1env LD_LIBRARY_PATH={{ emacs_library_path }} \2'
