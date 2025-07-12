import random
block_names = ["Travìná hlína", "Kámen", "Písek", "Prkna"]  # Pøidejte kolik blokù chcete (1 až 9223372036854775807)
rotation = "0|0|0"
y = 0
range_x = 30 # Kokik (X) krát
range_z = 30 # Kolik (Z) 
center_x = 0
center_z = 0
half_x = range_x // 2
half_z = range_z // 2
start_x = center_x - half_x
end_x = center_x + half_x
start_z = center_z - half_z
end_z = center_z + half_z
blocks = []
for z in range(start_z, end_z):
    for x in range(start_x, end_x):
        block_name = random.choice(block_names)
        block = f"{block_name}|{x}|{y}|{z}|{rotation};"
        blocks.append(block)
save_string = ''.join(blocks)[:-1]
print(save_string)
