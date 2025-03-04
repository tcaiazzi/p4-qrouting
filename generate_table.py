import itertools
import os
import sys


def non_reversed_permutations(iterable, num):
    for permutation in itertools.permutations(iterable, num):
        if permutation[0] < permutation[-1]:
            yield permutation


def main(num_nodes):
    node_list = [i for i in range(1, num_nodes + 1)]

    all_perms = []
    for i in range(1, num_nodes):
        if i > 1:
            unique_p = set()
            for p in non_reversed_permutations(node_list, i):
                sorted_p = tuple(sorted(list(p)))
                unique_p.add(sorted_p)
            all_perms.extend(unique_p)
        else:
            all_perms.extend(list(itertools.permutations(node_list, i)))

    all_perms.extend([tuple(node_list)])
    all_perms.sort()

    action_names = []
    actions = []
    for items in all_perms:
        items_str = "_".join(list([str(i) for i in items]))
        action_name = f"enable_{items_str}"
        action_header = f"action {action_name}() {{\n"
        
        action_body = ""
        for i, item in enumerate(items):
            action_body += f"    hdr.update_list[{item - 1}].setValid();\n"
            action_body += f"    hdr.update_list.next = " + ("0" if i == len(items) - 1 else "1") + ";\n"

        action_names.append(action_name)
        actions.append(action_header + action_body + "}\n")

    action_names_str = "\n".join([f"        {a};" for a in action_names])

    table_def = f"""table enable_updates {{
    key = {{
        dst_num: exact;
    }}
    actions = {{
{action_names_str}
    }}
    size = {len(action_names)};
}}"""

    final_str = "#ifndef __QLR_UPDATES__\n#define __QLR_UPDATES__\n\n" + "\n".join(actions) + table_def + "\n\n#endif"

    lut_path = os.path.join("lab", "shared", "p4src", "lut")
    os.makedirs(lut_path, exist_ok=True)
    with open(os.path.join(lut_path, "qlr_updates.p4"), "w") as p4_file:
        p4_file.write(final_str)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(
            "Usage: plot.py <num_nodes>"
        )
        exit(1)

    num_nodes = int(sys.argv[1])

    main(num_nodes)
