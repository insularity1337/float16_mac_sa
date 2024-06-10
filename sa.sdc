set period $env(PERIOD)
set uncertainty [expr $period * 0.05]

create_clock \
	-name CLK \
	-period $period \
	[get_db ports *CLK]

set_clock_uncertainty $uncertainty [get_db clocks *CLK]