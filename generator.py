block_name = "Travìná hlína"
rotation = "0|0|0"
y = 0
range_x = 30   # poèet blokù ve smìru X 
range_z = 30   # poèet blokù ve smìru Z 
center_x = 0   # støed osy X
center_z = 0   # støed osy Z
half_x = range_x // 2
half_z = range_z // 2
start_x = center_x - half_x
end_x = center_x + half_x
start_z = center_z - half_z
end_z = center_z + half_z
blocks = []
for z in range(start_z, end_z):
    for x in range(start_x, end_x):
        block = f"{block_name}|{x}|{y}|{z}|{rotation};"
        blocks.append(block)
save_string = ''.join(blocks)[:-1]
print(save_string)
