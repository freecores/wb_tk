library ieee;
use work.technology.all;
use ieee.std_logic_1164.all;

entity wb_async_master_tb is
	generic(
		width : POSITIVE := 16;
		addr_width : POSITIVE := 20 );
end wb_async_master_tb;

architecture TB of wb_async_master_tb is
	component wb_async_master
	generic(
		width : POSITIVE := 16;
		addr_width : POSITIVE := 20 );
	port(
		clk_i : in std_logic;
		rst_i : in std_logic;
		s_adr_o : out std_logic_vector((addr_width-1) downto 0);
		s_sel_o : out std_logic_vector(((width/8)-1) downto 0);
		s_dat_i : in std_logic_vector((width-1) downto 0);
		s_dat_o : out std_logic_vector((width-1) downto 0);
		s_cyc_o : out std_logic;
		s_ack_i : in std_logic;
		s_err_i : in std_logic;
		s_rty_i : in std_logic;
		s_we_o : out std_logic;
		s_stb_o : out std_logic;
		a_data : inout std_logic_vector((width-1) downto 0);
		a_addr : in std_logic_vector((addr_width-1) downto 0);
		a_rdn : in std_logic;
		a_wrn : in std_logic;
		a_cen : in std_logic;
		a_byen : in std_logic_vector(((width/8)-1) downto 0);
		a_waitn : out std_logic );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_i : std_logic;
	signal rst_i : std_logic;
	signal s_dat_i : std_logic_vector((width-1) downto 0);
	signal s_ack_i : std_logic;
	signal s_err_i : std_logic;
	signal s_rty_i : std_logic;
	signal a_data : std_logic_vector((width-1) downto 0);
	signal a_addr : std_logic_vector((addr_width-1) downto 0);
	signal a_rdn : std_logic;
	signal a_wrn : std_logic;
	signal a_cen : std_logic;
	signal a_byen : std_logic_vector(((width/8)-1) downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal s_adr_o : std_logic_vector((addr_width-1) downto 0);
	signal s_sel_o : std_logic_vector(((width/8)-1) downto 0);
	signal s_dat_o : std_logic_vector((width-1) downto 0);
	signal s_cyc_o : std_logic;
	signal s_we_o : std_logic;
	signal s_stb_o : std_logic;
	signal a_waitn : std_logic;

begin

	-- Unit Under Test port map
	UUT : wb_async_master port map( 
		clk_i => clk_i,
		rst_i => rst_i,
		s_adr_o => s_adr_o,
		s_sel_o => s_sel_o,
		s_dat_i => s_dat_i,
		s_dat_o => s_dat_o,
		s_cyc_o => s_cyc_o,
		s_ack_i => s_ack_i,
		s_err_i => s_err_i,
		s_rty_i => s_rty_i,
		s_we_o => s_we_o,
		s_stb_o => s_stb_o,
		a_data => a_data,
		a_addr => a_addr,
		a_rdn => a_rdn,
		a_wrn => a_wrn,
		a_cen => a_cen,
		a_byen => a_byen,
		a_waitn => a_waitn
	);
	
	-- Reset
	reset: process is
	begin
		rst_i <= '1';
		wait for 75ns;
		rst_i <= '0';
		wait;
	end process;
	
	-- Clock generator
	clock: process is
	begin
		wait for 25 ns;
		clk_i <= '1';
		wait for 25 ns;
		clk_i <= '0';
	end process;

	-- A WB slave which responses to each access	
	s_err_i <= '0';
	s_rty_i <= '0';
	s_ack_i <= s_stb_o;
	wb_slave: process is
	begin
		wait until clk_i'EVENT and clk_i = '1';
		if (s_stb_o = '1') then
--			s_ack_i <= '1'; -- signal ready (one WS)
			if (s_we_o = '0') then
				s_dat_i <= s_adr_o(s_dat_i'RANGE);
			end if;
		else
--			s_ack_i <= '0';
		end if;
	end process;
	
	-- An async master generating requests
	master: process is
		variable addr: std_logic_vector(a_addr'RANGE) := (others => '0');
	begin
		a_cen <= '1';
		a_wrn <= '1';
		a_rdn <= '1';
		a_byen <= (others => '1');
		a_data <= (others => 'Z');
		a_addr <= addr;
		wait for 200ns;
		a_cen <= '0';
		wait for 120ns;
		a_rdn <= '0';
		if (a_waitn = '1') then 
			wait until a_waitn = '0'; -- wait until wait is released
		end if;
		if (a_waitn = '0') then 
			wait until a_waitn = '1'; -- wait until wait is released
		end if;
		wait for 150ns;
		a_rdn <= '1';
		a_cen <= '1';
		wait for 70ns;
		a_wrn <= '0';
		a_data <= a_addr(a_data'RANGE);
		wait for 20ns;
		a_cen <= '0';
		if (a_waitn = '1') then 
			wait until a_waitn = '0'; -- wait until wait is released
		end if;
		if (a_waitn = '0') then 
			wait until a_waitn = '1'; -- wait until wait is released
		end if;
		wait for 15ns;
		a_wrn <= '1';
		a_cen <= '1';
		addr := add_one(addr);
	end process;
end TB;

configuration TB_wb_async_master of wb_async_master_tb is
	for TB
		for UUT : wb_async_master
			use entity work.wb_async_master(wb_async_master);
		end for;
	end for;
end TB_wb_async_master;

