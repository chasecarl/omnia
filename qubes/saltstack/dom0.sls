{% set user = salt['cmd.shell']('groupmems --list --group qubes') %}
{% set group = user %}
{% set redshift_conf_name = "redshift.conf" %}
{% set startup_scripts_dir = ".startupscripts" %}
{% set startup_scripts_dirpath = "/home/%s/%s" | format(user, startup_scripts_dir) %}
{% set redshift_wrapper_name = "redshift-wrapper.sh" %}
{% set redshift_desktop_name = "Redshift.desktop" %}
{% set autostart_dirpath = "/home/%s/.config/autostart" | format(user) %}
{% set redshift_desktop_path = "%s/%s" | format(autostart_dirpath, redshift_desktop_name) %}

# Redshift setup, as per
# https://forum.qubes-os.org/t/blue-light-filter-in-xfce-redshift/540
redshift:
  pkg.installed

# copy the Redshift config to ~/.config
/home/{{ user }}/.config/{{ redshift_conf_name }}:
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - source: salt://config/{{ redshift_conf_name }}

# copy the wrapper to ~/.startupscripts
{{ startup_scripts_dirpath }}:
  file.directory:
    - user: {{ user }}
    - group: {{ group }}
{{ startup_scripts_dirpath }}/{{ redshift_wrapper_name }}:
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 0755
    - source: salt://scripts/{{ redshift_wrapper_name }}

# copy the desktop entry to ~/.config/autostart
{{ autostart_dirpath }}:
  file.directory:
    - user: {{ user }}
    - group: {{ group }}
{{ redshift_desktop_path }}:
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - source: salt://config/{{ redshift_desktop_name }}
autostart-entry-points-to-the-script:
  file.replace:
    - name: {{ redshift_desktop_path }}
    - pattern: '^Exec=.*'
    - repl: Exec={{ startup_scripts_dirpath }}/{{ redshift_wrapper_name }}
# end Redshift setup
