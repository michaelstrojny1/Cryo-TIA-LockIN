import lockIn_pkg::*;

module magnitude (
    input  accumT      I,
    input  accumT      Q,
    output longAccumT  magOut
);

    longAccumT I_sq;
    longAccumT Q_sq;

    always_comb begin
        I_sq  = I * I;
        Q_sq  = Q * Q;
        magOut = I_sq + Q_sq;
    end

endmodule