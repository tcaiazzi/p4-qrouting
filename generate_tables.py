import itertools
import os
import sys


def non_reversed_permutations(iterable, num):
    for permutation in itertools.permutations(iterable, num):
        if permutation[0] < permutation[-1]:
            yield permutation


def generate_qmatrix_updates(path, node_list, perms):
    num_nodes = len(node_list)

    action_names = []
    actions = []
    for items in perms:
        items_str = "_".join(list([str(i) for i in items]))
        action_name = f"qmatrix_update_{items_str}"
        action_header = f"action {action_name}() {{\n"

        action_body = ""
        idx = 0
        for i in range (1, num_nodes + 1):
            if i in items:
                action_body += f"    row{i}.read(row{i}_value, 0);\n"
                slice_start = 8 * (i - 1)
                slice_end = (8 * i) - 1
                # Bellman formula
                row_slice = f"row{i}_value[{slice_end}:{slice_start}]"
                action_body += f"    log_msg(\"updating row{i}_value - before: {{}}\", {{{row_slice}}});\n"
                action_body += f"    {row_slice} = {row_slice} + (ig_qdepth + hdr.qlr_updates[{idx}].value - {row_slice});\n"
                action_body += f"    log_msg(\"updating row{i}_value - after: {{}}\", {{{row_slice}}});\n"
                action_body += f"    row{i}.write(0, row{i}_value);\n"
                idx += 1
            else:
                action_body += f"    log_msg(\"reading row{i}_value\");\n"
                action_body += f"    row{i}.read(row{i}_value, 0);\n"
        
        action_names.append(action_name)
        actions.append(action_header + action_body + "}\n")

        action_names_str = "\n".join([f"        {a};" for a in action_names])

        keys = ""
        for node in node_list:
            keys += f"        hdr.qlr_updates[{node - 1}].isValid(): exact;\n"
            keys += f"        hdr.qlr_updates[{node - 1}].dst_id: exact;\n"
        keys = keys[:-1]

    action_read_all = "action read_all() {\n"
    for node in node_list:
        action_read_all += f"    log_msg(\"reading row{node}_value\");\n"
        action_read_all += f"    row{node}.read(row{node}_value, 0);\n"
    action_read_all += "}\n"

    table_def = f"""table qmatrix_update {{
    key = {{
{keys}
    }}
    actions = {{
{action_names_str}
        read_all;
    }}
    size = {len(action_names) + 1};
    default_action = read_all;
}}"""

    final_str = "#ifndef __QMATRIX_UPDATE__\n#define __QMATRIX_UPDATE__\n\n" + "\n".join(actions) + f"\n{action_read_all}\n" + table_def + "\n\n#endif"

    os.makedirs(path, exist_ok=True)
    with open(os.path.join(path, "qmatrix_update.p4"), "w") as p4_file:
        p4_file.write(final_str)


def generate_qlr_updates(path, node_list, perms):
    num_nodes = len(node_list)

    action_names = []
    actions = []
    for items in perms:
        items_str = "_".join(list([str(i) for i in items]))
        action_name = f"qlr_pkt_set_{items_str}"
        action_header = f"action {action_name}() {{\n"
        
        action_body = ""
        for i, item in enumerate(items):
            action_body += f"    hdr.qlr_updates[{item - 1}].setValid();\n"
            action_body += f"    hdr.qlr_updates[{item - 1}].has_next = " + ("0" if i == len(items) - 1 else "1") + ";\n"
            action_body += f"    log_msg(\"set valid: hdr.qlr_updates[{item - 1}]\");\n"

        action_names.append(action_name)
        actions.append(action_header + action_body + "}\n")

    action_names_str = "\n".join([f"        {a};" for a in action_names])

    table_def = f"""table qlr_pkt_updates {{
    key = {{
        row_num: exact;
    }}
    actions = {{
{action_names_str}
    }}
    size = {len(action_names)};
}}"""

    final_str = "#ifndef __QLR_PKT_UPDATES__\n#define __QLR_PKT_UPDATES__\n\n" + "\n".join(actions) + "\n" + table_def + "\n\n#endif"

    os.makedirs(path, exist_ok=True)
    with open(os.path.join(path, "qlr_pkt_updates.p4"), "w") as p4_file:
        p4_file.write(final_str)


def main(n):
    n_list = [i for i in range(1, n + 1)]

    all_perms = []
    for i in range(1, n):
        if i > 1:
            unique_p = set()
            for p in non_reversed_permutations(n_list, i):
                sorted_p = tuple(sorted(list(p)))
                unique_p.add(sorted_p)
            all_perms.extend(unique_p)
        else:
            all_perms.extend(list(itertools.permutations(n_list, i)))

    all_perms.extend([tuple(n_list)])
    all_perms.sort()

    lut_path = os.path.join("lab", "shared", "p4src", "lut")

    generate_qmatrix_updates(lut_path, n_list, all_perms)
    generate_qlr_updates(lut_path, n_list, all_perms)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(
            "Usage: plot.py <num_nodes>"
        )
        exit(1)

    num_nodes = int(sys.argv[1])

    main(num_nodes)
