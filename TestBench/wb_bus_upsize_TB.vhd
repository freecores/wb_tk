library ieee,synopsys;
use work.technology.all;
use ieee.std_logic_1164.all;
use synopsys.std_logic_arith.all;

entity wb_bus_upsize_tb is
	generic (
		m_bus_width: positive := 8; -- master bus width
		m_addr_width: positive := 21; -- master bus width
		s_bus_width: positive := 64; -- slave bus width
		s_addr_width: positive := 18; -- master bus width
		little_endien: boolean := true -- if set to false, big endien
	);
end wb_bus_upsize_tb;

architecture TB of wb_bus_upsize_tb is
	component wb_bus_upsize is
		generic (
			m_bus_width: positive := m_bus_width;
			m_addr_width: positive := m_addr_width;
			s_bus_width: positive := s_bus_width;
			s_addr_width: positive := s_addr_width;
			little_endien: boolean := little_endien
		);
		port (
	--		clk_i: in std_logic;
	--		rst_i: in std_logic := '0';
	
			-- Master bus interface
			m_adr_i: in std_logic_vector (m_addr_width-1 downto 0);
			m_sel_i: in std_logic_vector ((m_bus_width/8)-1 downto 0) := (others => '1');
			m_dat_i: in std_logic_vector (m_bus_width-1 downto 0);
			m_dat_oi: in std_logic_vector (m_bus_width-1 downto 0) := (others => '-');
			m_dat_o: out std_logic_vector (m_bus_width-1 downto 0);
			m_cyc_i: in std_logic;
			m_ack_o: out std_logic;
			m_ack_oi: in std_logic := '-';
			m_err_o: out std_logic;
			m_err_oi: in std_logic := '-';
			m_rty_o: out std_logic;
			m_rty_oi: in std_logic := '-';
			m_we_i: in std_logic;
			m_stb_i: in std_logic;
	
			-- Slave bus interface
			s_adr_o: out std_logic_vector (s_addr_width-1 downto 0);
			s_sel_o: out std_logic_vector ((s_bus_width/8)-1 downto 0);
			s_dat_i: in std_logic_vector (s_bus_width-1 downto 0);
			s_dat_o: out std_logic_vector (s_bus_width-1 downto 0);
			s_cyc_o: out std_logic;
			s_ack_i: in std_logic;
			s_err_i: in std_logic := '-';
			s_rty_i: in std_logic := '-';
			s_we_o: out std_logic;
			s_stb_o: out std_logic
		);
	end component;

	signal m_adr_i : std_logic_vector((m_addr_width-1) downto 0) := (others => '0');
	signal m_sel_i : std_logic_vector(((m_bus_width/8)-1) downto 0) := (others => '0');
	signal m_dat_i : std_logic_vector((m_bus_width-1) downto 0);
	signal m_dat_oi : std_logic_vector((m_bus_width-1) downto 0) := (others => 'U');
	signal m_cyc_i : std_logic;
	signal m_ack_oi : std_logic := 'U';
	signal m_err_oi : std_logic := 'U';
	signal m_rty_oi : std_logic := 'U';
	signal m_we_i : std_logic;
	signal m_stb_i : std_logic;
	signal s_dat_i : std_logic_vector((s_bus_width-1) downto 0);
	signal s_ack_i : std_logic;
	signal s_err_i : std_logic := '0';
	signal s_rty_i : std_logic := '0';

	signal m_dat_o : std_logic_vector((m_bus_width-1) downto 0);
	signal m_ack_o : std_logic;
	signal m_err_o : std_logic;
	signal m_rty_o : std_logic;
	signal s_adr_o : std_logic_vector(s_addr_width-1 downto 0);
	signal s_sel_o : std_logic_vector(((s_bus_width/8)-1) downto 0);
	signal s_dat_o : std_logic_vector((s_bus_width-1) downto 0);
	signal s_cyc_o : std_logic;
	signal s_we_o : std_logic;
	signal s_stb_o : std_logic;

begin

	-- Unit Under Test port map
	UUT : wb_bus_upsize
		port map
			(m_adr_i => m_adr_i,
			m_sel_i => m_sel_i,
			m_dat_i => m_dat_i,
			m_dat_oi => m_dat_oi,
			m_dat_o => m_dat_o,
			m_cyc_i => m_cyc_i,
			m_ack_o => m_ack_o,
			m_ack_oi => m_ack_oi,
			m_err_o => m_err_o,
			m_err_oi => m_err_oi,
			m_rty_o => m_rty_o,
			m_rty_oi => m_rty_oi,
			m_we_i => m_we_i,
			m_stb_i => m_stb_i,
			s_adr_o => s_adr_o,
			s_sel_o => s_sel_o,
			s_dat_i => s_dat_i,
			s_dat_o => s_dat_o,
			s_cyc_o => s_cyc_o,
			s_ack_i => s_ack_i,
			s_err_i => s_err_i,
			s_rty_i => s_rty_i,
			s_we_o => s_we_o,
			s_stb_o => s_stb_o );

	s_ack_i <= s_stb_o;
	slave: process is
	begin
		for i in s_sel_o'RANGE loop
			s_dat_i(8*i+7 downto 8*i+0) <= CONV_STD_LOGIC_VECTOR(i,8);
		end loop;
		wait;
	end process;
	
	-- A machine which generates all signals
	m_cyc_i <= m_stb_i;
	master: process is
	begin
		for i in m_dat_i'RANGE loop
			if (i mod 2 = 1) then
				m_dat_i(i) <= '1';
			else
				m_dat_i(i) <= '0';
			end if;
		end loop;
		m_sel_i(0) <= '1';
		m_we_i <= '0';
		m_stb_i <= '0';
		wait for 100ns;
		m_we_i <= '0';
		m_stb_i <= '1';
		wait for 100ns;
		m_we_i <= '0';
		m_stb_i <= '0';
		wait for 100ns;
		m_we_i <= '1';
		m_stb_i <= '1';
		wait for 100ns;
		m_adr_i <= add_one(m_adr_i);
	end process;
end TB;

configuration TB_wb_bus_upsize of wb_bus_upsize_tb is
	for TB
		for UUT : wb_bus_upsize
			use entity work.wb_bus_upsize(wb_bus_upsize);
		end for;
	end for;
end TB_wb_bus_upsize;

