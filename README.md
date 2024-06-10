Multiplier-accumulator systolic array for general purpose matrix multiplications.<br>
Float16 support with NaN, Inf, Zero. No rounding, just simple cut at internal stages.<br>
`src/sa.sv` - top.<br>

4x4 synthesis with skywater 130nm high-speed library and 80% toggle rate of data ports:
| max freq (MHz) | total area  | power (W)   |
|---             |:---:        |:---:        |
| 50             | 604808.886  | 6.63211e-02 |
| 100            | 641758.578  | 1.37625e-01 |
| 150            | 661357.395  | 2.04897e-01 |
| 200            | 746384.623  | 2.92419e-01 |
| 250            | 784572.329  | 3.83024e-01 |
| 300            | 802224.233  | 4.75264e-01 |
