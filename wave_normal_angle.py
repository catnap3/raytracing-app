import pandas as pd
import numpy as np
import logging
DATA_DIR = "./data/plot_data.dat"
logging.basicConfig(level=logging.DEBUG)

def get_data_from_dat():
    data = []
    with open(DATA_DIR, "r") as file:
        for line in file:
            row = line.strip().split("\t")
            data.append(row)
    df = pd.DataFrame(data[1:], columns=data[0])
    return df
data_frame = get_data_from_dat()
if __name__ == "__main__":
    logging.debug(data_frame.head())

def calculate_wave_normal_angle():
    wave_normal_angles = []
    for index, row in data_frame.iterrows():
        x,y,u,v = float(row["x"]), float(row["y"]), float(row["u"]), float(row["v"])
        x_prime = x
        y_prime = 0
        z_prime = y
        r = np.sqrt(x_prime**2+y_prime**2+z_prime**2)
        wave_normal_angle = np.arccos(-( (3*x_prime*z_prime*u) + (3*z_prime**2-r**2)*v ) / ( np.sqrt( (((3*x_prime*z_prime)**2)+(3*z_prime**2-r**2)**2) * np.sqrt(u**2+v**2) ) ))
        wave_normal_angles.append(np.degrees(wave_normal_angle))
    data_frame["wna[°]"] = wave_normal_angles # wave normal angle
    return data_frame
data_frame = calculate_wave_normal_angle()
if __name__ == "__main__":
    logging.debug(data_frame.head())

def calculate_latitude():
    latitudes = []
    for index, row in data_frame.iterrows():
        x,y,u,v = float(row["x"]), float(row["y"]), float(row["u"]), float(row["v"])
        x_prime = x
        y_prime = 0
        z_prime = y
        lattitude = 90 + abs( np.degrees(np.arctan(z_prime/x_prime)) )
        latitudes.append(lattitude)
    data_frame["lat[°]"] = latitudes
    return data_frame
data_frame = calculate_latitude()
if __name__ == "__main__":
    logging.debug(data_frame.head())

"""
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.max_colwidth', None)
OUTPUT_CSV_FILE = "./data/wave_normal_angle.csv"
thetas.to_csv(OUTPUT_CSV_FILE, index=False, lineterminator='')
"""

OUTPUT_DAT_FILE = "./data/wave_normal_angle.dat"
with open(OUTPUT_DAT_FILE, "w") as output_file:
    output_file.write(data_frame.to_string(index=False, header=True))