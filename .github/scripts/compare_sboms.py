#!/usr/bin/env python3
import json
import sys

def load_sbom(filepath):
    with open(filepath, 'r') as f:
        data = json.load(f)
    packages = {}
    for artifact in data.get('artifacts', []):
        name = artifact.get('name')
        version = artifact.get('version')
        pkg_type = artifact.get('type')
        if name:
            # Key by name and type to handle same name in different ecosystems (e.g. deb vs python)
            packages[(name, pkg_type)] = version
    return packages

def main():
    if len(sys.argv) < 3:
        print("Usage: compare_sboms.py <base_sbom.json> <built_sbom.json>")
        sys.exit(1)

    base_file = sys.argv[1]
    built_file = sys.argv[2]

    base_pkgs = load_sbom(base_file)
    built_pkgs = load_sbom(built_file)

    added = []
    removed = []
    changed = []

    for (name, pkg_type), version in built_pkgs.items():
        if (name, pkg_type) not in base_pkgs:
            added.append((name, version, pkg_type))
        elif base_pkgs[(name, pkg_type)] != version:
            changed.append((name, base_pkgs[(name, pkg_type)], version, pkg_type))

    for (name, pkg_type), version in base_pkgs.items():
        if (name, pkg_type) not in built_pkgs:
            removed.append((name, version, pkg_type))

    print("=== SBOM Comparison ===")
    if added:
        print(f"\nAdded packages ({len(added)}):")
        for name, version, pkg_type in sorted(added):
            print(f"  + {name} {version} ({pkg_type})")
    
    if changed:
        print(f"\nChanged packages ({len(changed)}):")
        for name, old_v, new_v, pkg_type in sorted(changed):
            print(f"  * {name} {old_v} -> {new_v} ({pkg_type})")

    if removed:
        print(f"\nRemoved packages ({len(removed)}):")
        for name, version, pkg_type in sorted(removed):
            print(f"  - {name} {version} ({pkg_type})")

    if not added and not changed and not removed:
        print("No package changes detected.")

if __name__ == "__main__":
    main()
