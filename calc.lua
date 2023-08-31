
local function input(p)
    write(p.."> ")
    return read()
end
local function inputNumber(p)
    return tonumber(input(p))
end
local turbineHeight = inputNumber("turbineHeight")
local structure = {}
structure.volLength = inputNumber("structure.volLength")
structure.volWidth = structure.volLength
structure.lowerVolume = structure.volLength*structure.volWidth*turbineHeight
print("TURBINE_STORED")
local TURBINE_STORED_AMOUNT = inputNumber("TURBINE_STORED_AMOUNT")
local TURBINE_MAX_STORED_AMOUNT = inputNumber("TURBINE_MAX_STORED_AMOUNT")
print("TURBINE_DISPENSER")
local TURBINE_DISPENSER_COUNT = inputNumber("TURBINE_DISPENSER_COUNT")
local GENERAL_DISPENSER_GAS_FLOW = inputNumber("GENERAL_DISPENSER_GAS_FLOW")
print("TURBINE_DISPERSER")
local TURBINE_DISPERSER_COUNT = inputNumber("TURBINE_DISPERSER_COUNT")
local GENERAL_DISPERSER_GAS_FLOW = inputNumber("GENERAL_DISPERSER_GAS_FLOW")
print("TURBINE_VENT")
local TURBINE_VENT_COUNT = inputNumber("TURBINE_VENT_COUNT")
local GENERAL_VENT_GAS_FLOW = inputNumber("GENERAL_VENT_GAS_FLOW")
local GENERAL_MAX_ENERGY_PER_STEAM = inputNumber("GENERAL_MAX_ENERGY_PER_STEAM")
print("TURBINE_BLADES")
local TURBINE_MAX_BLADES =inputNumber("TURBINE_MAX_BLADES") or 18
local TURBINE_BLADE_COUNT = inputNumber("TURBINE_BLADE_COUNT")
local TURBINE_COIL_COUNT = inputNumber("TURBINE_COIL_COUNT")
print("Energy")
local MaxEnergy = inputNumber("MaxEnergy")
local Energy = inputNumber("Energy")
local flow = (
    math.min(
        math.min(
            TURBINE_STORED_AMOUNT,
            math.min(
                structure.lowerVolume
                *
                (
                    TURBINE_DISPERSER_COUNT*GENERAL_DISPERSER_GAS_FLOW
                ),
                TURBINE_VENT_COUNT*GENERAL_VENT_GAS_FLOW
            )),(
            (
                MaxEnergy-Energy
            )
            /
            (
                (GENERAL_MAX_ENERGY_PER_STEAM/TURBINE_MAX_BLADES)
                *
                math.min(
                    TURBINE_BLADE_COUNT,
                    TURBINE_COIL_COUNT*2
                )
            )
        )
    )*(
        TURBINE_STORED_AMOUNT/TURBINE_MAX_STORED_AMOUNT
    )
)/(
    math.min(
        structure.lowerVolume
        *
        (
            TURBINE_DISPENSER_COUNT*GENERAL_DISPENSER_GAS_FLOW
        ),
        TURBINE_VENT_COUNT*GENERAL_VENT_GAS_FLOW
    )
)
print(("0x%x"):format(flow))