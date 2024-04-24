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

def calculate_degree():
    thetas = []
    for index, row in data_frame.iterrows():
        x,y,u,v = float(row["x"]), float(row["y"]), float(row["u"]), float(row["v"])
        x_prime = x
        y_prime = 0
        z_prime = y
        r = np.sqrt(x_prime**2+y_prime**2+z_prime**2)
        theta = np.arccos(-( (3*x_prime*z_prime*u) + (3*z_prime**2-r**2)*v ) / ( np.sqrt( (((3*x_prime*z_prime)**2)+(3*z_prime**2-r**2)**2) * np.sqrt(u**2+v**2) ) ))
        thetas.append(np.degrees(theta))
    data_frame[r'$\theta$ [°]'] = thetas
    return data_frame
thetas = calculate_degree()
print(thetas)