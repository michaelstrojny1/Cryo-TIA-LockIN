import lockIn_pkg::*;

module magnitude (
    input  accumT      I,
    input  accumT      Q,
    output longAccumT  magOut
);

    // ------------------------------------------------------------
    // Compute signal magnitude squared
    //
    // |A|^2 = I^2 + Q^2
    //
    // Using magnitude squared avoids expensive square-root
    // hardware while still representing signal power.
    // ------------------------------------------------------------

    always_comb begin
        magOut = longAccumT'(I) * longAccumT'(I) +
                 longAccumT'(Q) * longAccumT'(Q);
    end

endmodule