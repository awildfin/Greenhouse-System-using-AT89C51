# Automated Greenhouse Control System Simulation Project
This project is a simulation of an automated greenhouse environmental control system using Proteus software. The system is designed to monitor and maintain ideal environmental conditions for plants, such as temperature, air humidity, light intensity, and soil moisture.

The system is controlled by an AT89C51 microcontroller programmed in Assembly language.

# ✨ Key Features
- **Real-time Monitoring**: The system continuously monitors 4 environmental parameters:

1. **Air Temperature (LM35)**

2. **Air Humidity (HIH5030)**

3. **Light Intensity (TSL251RD)**

4. **Soil Moisture (simulated with a potentiometer)**

- **Automatic Control**: Actuators operate automatically based on predefined threshold values.

- **LCD Display**: All sensor data is displayed in real-time on a 4x20 LCD screen for easy monitoring.

# 🛠️ Components Used
**Hardware (Simulation)**
- **Microcontroller**: AT89C51

- **Sensors**:

  - `LM35`: Temperature Sensor

  - `HIH5030`: Air Humidity Sensor

  - `TSL251RD`: Light Sensor

  - `Potentiometer`: To simulate a Soil Moisture Sensor

- **Actuators**:

  - `Heater`: Represented by an LED & Transistor

  - `Cooling Fan`: DC Motor

  - `Growlight`: Represented by an LED & Transistor

  - `Sprayer`: DC Motor

  - `Servo Motor`: Controls ventilation

- **Supporting Components**:

  - `ADC0804`: Analog to Digital Converter

  - `4052`: Multiplexer, to select sensor input

  - `L293D`: Motor Driver to control the fan and sprayer

  - `LM041L`: 4x20 LCD Display

  - Crystal oscillator circuit, resistors, and capacitors.

**Software**
- Design & Simulation: Proteus Design Suite

- Programming Language: Assembly (8051)

- Compiler/Assembler: Keil uVision or another compatible assembler.

# ⚙️ How the System Works
1. Sensor Reading: The AT89C51 microcontroller sequentially selects input from each sensor via the Multiplexer (4052).

2. Signal Conversion: The analog signal from the sensors is converted to a digital signal by the ADC0804.

3. Data Processing: The received digital data is then processed and converted into appropriate units (degrees Celsius for temperature, and percentage for others).

4. Data Display: The converted results from each sensor are displayed on the LCD screen.

5. Actuator Activation: The microcontroller will activate or deactivate the actuators based on the following logic:

  - **Heater**: `ON` if temperature `< 23°C`.

  - **Cooling Fan**: `ON` if temperature `> 27°C`.

  - **Growlight**: `ON` if light intensity `< 30%`.

  - **Sprayer**: `ON` if soil moisture `< 40%`.

  - **Ventilation (Servo)**: `OPEN` if air humidity `> 40%`.

# 🚀 How to Run the Simulation
1. **Clone the Repository**:
   
```
git clone https://github.com/awildfin/Greenhouse-System-using-AT89C51.git
```

2. **Open the Project**: Open the GREENHOUSE_SYSTEM.pdsprj file using Proteus software.

3. **Load the Firmware**: Check the AT89C51 microcontroller component and ensure its program file is pointing to the .HEX file included in the project.

4. **Run the Simulation**: Click the "Play" button (▶️) at the bottom left corner to start the simulation.

5. **Test**: Change the values on the potentiometer or other sensors to observe the actuator responses and the updated values on the LCD.

# 📂 File Structure
- `GREENHOUSE_SYSTEM.pdsprj`: The main Proteus project file.

- `GREENHOUSE ASSEMBLY PROGRAM.asm`: The Assembly source code for the AT89C51 microcontroller.

- `Screenshot 2025-09-03 104900.png`: The circuit schematic image.

Happy building!
