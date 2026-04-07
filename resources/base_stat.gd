extends Resource
class_name BaseStat

@export var display_text: String = ""
## Description shown when hovering and in store. Max length = 43.
@export_multiline var description: String = ""

@export var max_level: int = 1000

@export_group("Value Curve")
@export var value_curve_type: ValueCurveType
@export var value_rounding_type: ValueRoundingType
@export_subgroup("Approaches Zero")
@export var approaches_zero_base: float
@export_subgroup("Approaches Const")
@export var const_start_value: float
@export var approaches_const: float
@export_subgroup("No Curve")
@export var base_value: float
@export var base_value_int: int

@export_group("Cost Curve")
@export var cost_type: CostCurveType
@export var base_cost: float
@export var power: float

var level: int = 0
## Percent bonus used in APPROACHES formulas.
var percent_bonus: float = 0.0
var point_bonus: float = 0.0
var point_bonus_int: int = 0

func get_upgrade_cost() -> int:
	match cost_type:
		CostCurveType.POWER: return ceil(base_cost * pow(power, level))
		CostCurveType.LINEAR: return ceil(base_cost + (base_cost * level))
		CostCurveType.FLAT: return ceil(base_cost)
	return 100000

func get_current_value() -> float:
	var val := 1.0
	
	match value_curve_type:
		ValueCurveType.APPROACHES_ZERO: val = approaches_zero_base / (1.0 + percent_bonus) + point_bonus
		ValueCurveType.APPROACHES_CONST: val = approaches_const - ((approaches_const - const_start_value) / (1.0 + percent_bonus)) + point_bonus
		ValueCurveType.NO_CURVE: val = (base_value + point_bonus) * (1 + percent_bonus)
	
	match value_rounding_type:
		ValueRoundingType.NONE: return val
		ValueRoundingType.FLOOR: return floor(val)
		ValueRoundingType.CEIL: return ceil(val)
	
	return val

func get_current_value_int() -> int:
	var val := (base_value_int + point_bonus_int) * (1 + percent_bonus)
	
	match value_rounding_type:
		ValueRoundingType.NONE: return floori(val)
		ValueRoundingType.FLOOR: return floori(val)
		ValueRoundingType.CEIL: return ceili(val)
	
	return floori(val)

## [b]APPROACHES_ZERO[/b]: approaches_zero_base / (1.0 + percent_bonus) + point_bonus[br][br]
## [b]APPROACHES_CONST[/b]: approaches_const - (approaches_const_base / (1.0 + percent_bonus)) + point_bonus[br][br]
## [b]NO_CURVE[/b]: (base_value + point_bonus) * (1 + percent_bonus)
enum ValueCurveType {
	APPROACHES_ZERO = 0,
	APPROACHES_CONST = 1,
	NO_CURVE = 2,
}

## Determines final rounding of value after applying curve.
enum ValueRoundingType {
	NONE = 0,
	FLOOR = 1,
	CEIL = 2,
}

## [b]POWER[/b]: ceil(base_cost * pow(power, level))[br][br]
## [b]LINEAR[/b]: base_cost + (base_cost * level)[br][br]
## [b]FLAT[/b]: base_cost
enum CostCurveType {
	POWER = 0,
	LINEAR = 1,
	FLAT = 2,
}
