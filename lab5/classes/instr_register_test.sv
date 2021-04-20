/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 *
 * SystemVerilog Training Workshop.
 * Copyright 2006, 2013 by Sutherland HDL, Inc.
 * Tualatin, Oregon, USA.  All rights reserved.
 * www.sutherland-hdl.com
 **********************************************************************/

module instr_register_test (tb_ifc io);  // interface port

  timeunit 1ns/1ns;

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  int seed = 555;

  class Transaction;
    rand opcode_t       opcode;
    rand operand_t      operand_a, operand_b;
    address_t      write_pointer;
    static int temp = 0;
   
    constraint const_operand_a {
      operand_a >= -15;
      operand_a <= 15;
    }

    constraint const_operand_b {
      operand_b >= 0;
      operand_b <= 15;
    }

    function void print_transaction();
      $display("Writing to register location %0d: ", write_pointer);
      $display("  opcode = %0d (%s)", opcode, opcode.name);
      $display("  operand_a = %0d",   operand_a);
      $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  endclass : Transaction

  class Driver;
    Transaction tr;
    virtual tb_ifc vifc;

    covergroup inputs_measure;
    
    cov_0: coverpoint vifc.cb.opcode {
      bins val_ZERO = {ZERO};
      bins val_PASSA = {PASSA};
      bins val_PASSB = {PASSB};
      bins val_ADD = {ADD};
      bins val_SUB = {SUB};
      bins val_MULT = {MULT};
      bins val_DIV = {DIV};
      bins val_MOD = {MOD};
    }
    
    cov_1: coverpoint vifc.cb.operand_a {
      bins val_operand_a[] = {[-15:15]};
    }

    cov_2: coverpoint vifc.cb.operand_b {
      bins val_operand_b[] = {[0:15]};
    }

    cov_3: coverpoint vifc.cb.operand_a {
      bins val_operand_a_pos = {[0:15]};
      bins val_operand_a_neg = {[-15:0]};
    }

    cov_4: cross cov_0, cov_3 {
      ignore_bins poz_ignore = binsof(cov_3.val_operand_a_pos);
    }

    cov_limit_opA: coverpoint vifc.cb.operand_a {
       bins val_operand_a_min_NEG = {-15};
       bins val_operand_a_max_POS = {15};
    }

    cov_limit_opB: coverpoint vifc.cb.operand_b {
       bins val_operand_b_ZERO = {0};
       bins val_operand_b_max_POS = {15};
    }

    cov_min_opA: coverpoint vifc.cb.operand_a {
       bins val_operand_a_MIN = {-15};
    }
    
    cov_min_opB: coverpoint vifc.cb.operand_b {
       bins val_operand_b_MIN = {0};
    }

    cov_5: cross cov_0, cov_limit_opA, cov_limit_opB {
    }

    cov_6: cross cov_0, cov_min_opA, cov_min_opB {
    }


    endgroup

    function new(virtual tb_ifc vifc);
      tr = new();
      this.vifc = vifc;
      inputs_measure = new();
    endfunction

    task reset_signals();
       $display("\nReseting the instruction register...");
       vifc.cb.write_pointer   <= 5'h00;      // initialize write pointer
       vifc.cb.read_pointer    <= 5'h1F;      // initialize read pointer
       vifc.cb.load_en         <= 1'b0;       // initialize load control line
       vifc.cb.reset_n         <= 1'b0;       // assert reset_n (active low)
    endtask

    task assign_signals();
      $display("\nWriting values to register stack...");
      @(vifc.cb) vifc.cb.load_en <= 1'b1;      // enable writing to register
      repeat (3) begin
        @(vifc.cb) tr.randomize();
        vifc.cb.write_pointer <= tr.temp++;
        vifc.cb.operand_a <= tr.operand_a;
        vifc.cb.operand_b <= tr.operand_b;
        vifc.cb.opcode <= tr.opcode;
        @(vifc.cb) tr.print_transaction;
        this.inputs_measure.sample();
      end
      @(vifc.cb) vifc.cb.load_en <= 1'b0;      // turn-off writing to register
    endtask

    task generate_transaction;
      this.reset_signals();
      repeat (2) @(vifc.cb) ;                // hold in reset for 2 clock cycles
      vifc.cb.reset_n         <= 1'b1;       // deassert reset_n (active low)
      this.assign_signals();
    endtask
  endclass: Driver

  class Monitor;
    virtual tb_ifc vifc;
    function new(virtual tb_ifc vifc);
      this.vifc = vifc;
    endfunction
    task read;
      for (int i=0; i<=2; i++) begin
      @(vifc.cb) vifc.cb.read_pointer <= i;
      @(vifc.cb) print_results;
    end
    endtask

    function void print_results();
        $display("Read from register location %0d: ", vifc.cb.read_pointer);
        $display("  opcode = %0d (%s)", vifc.cb.instruction_word.opc, vifc.cb.instruction_word.opc.name);
        $display("  operand_a = %0d",   vifc.cb.instruction_word.op_a);
        $display("  operand_b = %0d\n", vifc.cb.instruction_word.op_b);
    endfunction;
  endclass

  initial begin
    Driver drv;
    Monitor mon;
    drv = new(io);
    mon = new(io);
    drv.generate_transaction();
    mon.read();
    @(io.cb) $finish;
  end

endmodule: instr_register_test
