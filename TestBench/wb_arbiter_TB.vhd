library ieee;
use ieee.std_logic_1164.all;

library work;
use wb_tk.all;

entity wb_arbiter_tb is
end wb_arbiter_tb;

architecture TB of wb_arbiter_tb is
	-- Component declaration of the tested unit
	component wb_arbiter is
		port (
	--		clk: in std_logic;
			rst_i: in std_logic := '0';
			
			-- interface to master device a
			a_we_i: in std_logic;
			a_stb_i: in std_logic;
			a_cyc_i: in std_logic;
			a_ack_o: out std_logic;
			a_ack_oi: in std_logic := '-';
			a_err_o: out std_logic;
			a_err_oi: in std_logic := '-';
			a_rty_o: out std_logic;
			a_rty_oi: in std_logic := '-';
		
			-- interface to master device b
			b_we_i: in std_logic;
			b_stb_i: in std_logic;
			b_cyc_i: in std_logic;
			b_ack_o: out std_logic;
			b_ack_oi: in std_logic := '-';
			b_err_o: out std_logic;
			b_err_oi: in std_logic := '-';
			b_rty_o: out std_logic;
			b_rty_oi: in std_logic := '-';
	
			-- interface to shared devices
			s_we_o: out std_logic;
			s_stb_o: out std_logic;
			s_cyc_o: out std_logic;
			s_ack_i: in std_logic;
			s_err_i: in std_logic := '-';
			s_rty_i: in std_logic := '-';
			
			mux_signal: out std_logic; -- 0: select A signals, 1: select B signals
	
			-- misc control lines
			priority: in std_logic -- 0: A have priority over B, 1: B have priority over A
		);
	end component;

	signal clk_i:  std_logic;
	signal rst_i:  std_logic := '0';
	
	-- interface to master device a
	signal a_we_i:  std_logic;
	signal a_stb_i:  std_logic;
	signal a_cyc_i:  std_logic;
	signal a_ack_o:  std_logic;
	signal a_ack_oi:  std_logic := 'U';
	signal a_err_o:  std_logic;
	signal a_err_oi:  std_logic := 'U';
	signal a_rty_o:  std_logic;
	signal a_rty_oi:  std_logic := 'U';

	-- interface to master device b
	signal b_we_i:  std_logic;
	signal b_stb_i:  std_logic;
	signal b_cyc_i:  std_logic;
	signal b_ack_o:  std_logic;
	signal b_ack_oi:  std_logic := 'U';
	signal b_err_o:  std_logic;
	signal b_err_oi:  std_logic := 'U';
	signal b_rty_o:  std_logic;
	signal b_rty_oi:  std_logic := 'U';

	-- interface to shared devices
	signal s_we_o:  std_logic;
	signal s_stb_o:  std_logic;
	signal s_cyc_o:  std_logic;
	signal s_ack_i:  std_logic;
	signal s_err_i:  std_logic := 'U';
	signal s_rty_i:  std_logic := 'U';
	
	signal mux_signal:  std_logic; -- 0: select A signals, 1: select B signals

	-- misc control lines
	signal priority:  std_logic; -- 0: A have priority over B, 1: B have priority over A
	
	signal start: std_logic := '0';

begin

	-- Unit Under Test port map
	UUT : wb_arbiter
		port map (
			rst_i => rst_i,
			
			-- interface to master device a
			a_we_i => a_we_i,
			a_stb_i => a_stb_i,
			a_cyc_i => a_cyc_i,
			a_ack_o => a_ack_o,
			a_ack_oi => a_ack_oi,
			a_err_o => a_err_o,
			a_err_oi => a_err_oi,
			a_rty_o => a_rty_o,
			a_rty_oi => a_rty_oi,
		
			-- interface to master device b
			b_we_i => b_we_i,
			b_stb_i => b_stb_i,
			b_cyc_i => b_cyc_i,
			b_ack_o => b_ack_o,
			b_ack_oi => b_ack_oi,
			b_err_o => b_err_o,
			b_err_oi => b_err_oi,
			b_rty_o => b_rty_o,
			b_rty_oi => b_rty_oi,
	
			-- interface to shared devices
			s_we_o => s_we_o,
			s_stb_o => s_stb_o,
			s_cyc_o => s_cyc_o,
			s_ack_i => s_ack_i,
			s_err_i => s_err_i,
			s_rty_i => s_rty_i,
			
			mux_signal => mux_signal,
	
			-- misc control lines
			priority => priority
		);

	-- Reset the machine
	rst: process is
	begin
		rst_i <= '1';
		wait for 10ns;
		rst_i <= '0';
		start <= '1';
		wait;
	end process;
	
	clock: process is
	begin
		clk_i <= '0';
		wait for 10ns;
		clk_i <= '1';
		wait for 10ns;
	end process;
	
	-- Simulate a 3WS access time memory
	memory: process is
	begin
		s_ack_i <= '0';
		wait until (s_stb_o = '1' and clk_i'EVENT and clk_i = '1');
		wait until (clk_i'EVENT and clk_i = '1');
		wait until (clk_i'EVENT and clk_i = '1');
		wait until (clk_i'EVENT and clk_i = '1');
		s_ack_i <= '1';
		wait until (clk_i'EVENT and clk_i = '1');
	end process;

	-- Generate requests
	a_req: process is
	begin
		a_we_i <= '0';
		a_cyc_i <= '0';
		a_stb_i <= '0';
		wait for 100ns;
		a_cyc_i <= '1';
		a_stb_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and a_ack_o = '1';
		a_cyc_i <= '0';
		a_stb_i <= '0';
		wait for 20ns;
		a_cyc_i <= '1';
		a_stb_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and a_ack_o = '1';
		a_cyc_i <= '0';
		a_stb_i <= '0';
		-- Request 4 burst reads
		wait for 100ns;
		a_cyc_i <= '1';
		a_stb_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and a_ack_o = '1';
		wait until clk_i'EVENT and clk_i = '1' and a_ack_o = '1';
		wait until clk_i'EVENT and clk_i = '1' and a_ack_o = '1';
		wait until clk_i'EVENT and clk_i = '1' and a_ack_o = '1';
		a_cyc_i <= '0';
		a_stb_i <= '0';
	end process;

	b_req: process is
	begin
		b_we_i <= '0';
		b_cyc_i <= '0';
		b_stb_i <= '0';
		wait for 120ns;
		b_cyc_i <= '1';
		b_stb_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and b_ack_o = '1';
		b_cyc_i <= '0';
		b_stb_i <= '0';
		wait for 30ns;
		b_cyc_i <= '1';
		b_stb_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and b_ack_o = '1';
		b_cyc_i <= '0';
		b_stb_i <= '0';
		-- Request 4 burst reads
		wait for 120ns;
		b_cyc_i <= '1';
		b_stb_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and b_ack_o = '1';
		wait until clk_i'EVENT and clk_i = '1' and b_ack_o = '1';
		wait until clk_i'EVENT and clk_i = '1' and b_ack_o = '1';
		wait until clk_i'EVENT and clk_i = '1' and b_ack_o = '1';
		b_cyc_i <= '0';
		b_stb_i <= '0';
	end process;

	pri: process is
	begin
		priority <= '0';
		wait for 500ns;
		priority <= '1';
		wait for 500ns;
	end process;

end TB;

configuration TB_wb_arbiter of wb_arbiter_tb is
	for TB
		for UUT : wb_arbiter
			use entity wb_arbiter(FPGA);
		end for;
	end for;
end TB_wb_arbiter;

