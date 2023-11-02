{% set builder_networking_name = "builder-networking" %}

qubes-core-agent-networking:
  pkg.installed

# more minimal alternative to build-essential (checked Emacs with it)
# common-build-deps-installed:
#   pkg.installed:
#     - pkgs:
#       - git
#       - autoconf
#       - make
#       - texinfo

common-build-deps-installed:
  pkg.installed:
    - name: build-essential

# begin Emacs
deb-src-enabled:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: ^#(deb-src .* bookworm .*$)
    - repl: \1

# TODO: merge with 'deb-src-enabled'
repos-updated:
  cmd.run:
    - name: apt update

emacs-build-deps-installed:
  cmd.run:
    - name: apt build-dep -y emacs

emacs-additional-build-deps-installed:
  pkg.installed:
    - pkgs:
      # - libgccjit-12-dev  # maybe you need it if not using 'build-essential'?
      - libwebkit2gtk-4.0-dev
      - libtree-sitter-dev
      - libmagickwand-6.q16-dev
# end Emacs
