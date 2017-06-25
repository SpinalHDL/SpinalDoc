process(clk,reset)
begin
	if reset = '1' then
		...
	elsif rising_edge(clk) then
		...
	end if;
end process;


architecture arch of something is
  signal sub_condA : std_logic;
  signal sub_condB : std_logic;
  signal sub_result : std_logic;
  
  component SubComponent
    port(condA  : in std_logic;
	     condB  : in std_logic;
	     result : in std_logic);
  end component;
begin
  sub : SubComponent 
	port map (condA  => sub_condA 
	          condB  => sub_condB 
	          result => sub_result);
end arch;





entity UartCtrl is
  port( 
    config_frame_dataLength : in unsigned(2 downto 0);
    config_frame_stop : in UartStopType_binary_sequancial_type;
    config_frame_parity : in UartParityType_binary_sequancial_type;
    config_clockDivider : in unsigned(19 downto 0);
    
    write_valid : in std_logic;
    write_ready : out std_logic;
    write_payload : in std_logic_vector(7 downto 0);
    
    read_valid : out std_logic;
    read_payload : out std_logic_vector(7 downto 0);
    
    uart_txd : out std_logic;
    uart_rxd : in std_logic;
    axiClk : in std_logic;
    resetCtrl_axiReset : in std_logic 
  );
end UartCtrl;

  signal uartctrl_config_dataLength :  unsigned(2 downto 0);
  signal uartctrl_config_stop      :  UartStopType;
  signal uartctrl_config_parity    :  UartParityType;
  signal uartctrl_config_clockDivider    :  unsigned(19 downto 0);
  
  signal uartctrl_write_valid   :  std_logic;
  signal uartctrl_write_ready   :  std_logic;
  signal uartctrl_write_payload :  std_logic_vector(7 downto 0);
  
  signal uartctrl_read_valid   :  std_logic;
  signal uartctrl_read_payload :  std_logic_vector(7 downto 0);
  
  uartCtrl : entity work.UartCtrl
    port map ( 
        clk   => clk,
        reset => reset,
    
        config_dataLength => uartctrl_config_dataLength,
        config_stop       => uartctrl_config_stop,
        config_parity     => uartctrl_config_parity,
        config_clockDivider     => uartctrl_config_clockDivider,
    
        write_valid   => uartctrl_write_valid,
        write_ready   => uartctrl_write_ready,
        write_payload => uartctrl_write_payload,
    
        read_valid   => uartctrl_read_valid,
        read_payload => uartctrl_read_payload,
    
        uart_txd => uart_txd,
        uart_rxd => uart_rxd
    );
    
    
    
  source_aw_ready <= sink_aw_ready;
  source_w_ready <= sink_w_ready;
  source_b_valid <= sink_b_valid;
  source_b_id <= sink_b_id;
  source_b_resp <= sink_b_resp;
  source_ar_ready <= sink_ar_ready;
  source_r_valid <= sink_r_valid;
  source_r_data <= sink_r_data;
  source_r_id <= sink_r_id;
  source_r_resp <= sink_r_resp;
  source_r_last <= sink_r_last;
  sink_aw_valid <= source_aw_valid;
  sink_aw_addr <= source_aw_addr;
  sink_aw_id <= source_aw_id;
  sink_aw_region <= source_aw_region;
  sink_aw_len <= source_aw_len;
  sink_aw_size <= source_aw_size;
  sink_aw_burst <= source_aw_burst;
  sink_aw_lock <= source_aw_lock;
  sink_aw_cache <= source_aw_cache;
  sink_aw_qos <= source_aw_qos;
  sink_aw_prot <= source_aw_prot;
  sink_w_valid <= source_w_valid;
  sink_w_data <= source_w_data;
  sink_w_strb <= source_w_strb;
  sink_w_last <= source_w_last;
  sink_b_ready <= source_b_ready;
  sink_ar_valid <= source_ar_valid;
  sink_ar_addr <= source_ar_addr;
  sink_ar_id <= source_ar_id;
  sink_ar_region <= source_ar_region;
  sink_ar_len <= source_ar_len;
  sink_ar_size <= source_ar_size;
  sink_ar_burst <= source_ar_burst;
  sink_ar_lock <= source_ar_lock;
  sink_ar_cache <= source_ar_cache;
  sink_ar_qos <= source_ar_qos;
  sink_ar_prot <= source_ar_prot;
  sink_r_ready <= source_r_ready;
  
  
    signal source_valid : std_logic;
    signal source_ready : std_logic;
    signal source_r     : unsigned(4 downto 0);
    signal source_g     : unsigned(5 downto 0);
    signal source_b     : unsigned(4 downto 0);
    
    signal sink_valid : std_logic;
    signal sink_ready : std_logic;
    signal sink_r     : unsigned(4 downto 0);
    signal sink_g     : unsigned(5 downto 0);
    signal sink_b     : unsigned(4 downto 0);
    
    fifo_inst : entity work.Fifo
      generic map (
        depth         => 16,
        payload_width => 16
      )
      port map ( 
        clk => clk,
        reset => reset,
        push_valid => source_valid,
        push_ready => source_ready,
        push_payload(4  downto  0)   => source_payload_r,
        push_payload(10 downto  5)  => source_payload_g,
        push_payload(15 downto 11) => source_payload_b,
        pop_valid => sink_valid,
        pop_ready => sink_ready,
        pop_payload(4  downto  0)   => sink_payload_r,
        pop_payload(10 downto  5)  => sink_payload_g,
        pop_payload(15 downto 11) => sink_payload_b
      );
      
      
      
      
type address_array_type is array (0 to 3) of unsigned(7 downto 0);
signal addresses : address_array_type;
signal key       : unsigned(7 downto 0);
signal hits      : std_logic_vector(3 downto 0);
signal hit       : std_logic;

for i in addresses'range generate
  hits <= 
end generate;
