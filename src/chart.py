import pandas as pd
import matplotlib.pyplot as plt

# --- CONFIGURAÇÃO ---
# Coloque aqui o nome do arquivo do teste de 150 usuários
ARQUIVO_CSV = 'resultados/resultados_150users_2m_20251215_174322/dados_stats_history.csv' 

# Carregar dados
data = pd.read_csv(ARQUIVO_CSV)

# Converter Timestamp para segundos relativos (começando do zero)
start_time = data['Timestamp'].min()
data['Time_Sec'] = data['Timestamp'] - start_time

# Filtrar apenas a linha "Aggregated" (Média geral)
df_agg = data[data['Name'] == 'Aggregated']

# --- GRÁFICO 1: RPS e USUÁRIOS ---
fig, ax1 = plt.subplots(figsize=(10, 6))

color = 'tab:blue'
ax1.set_xlabel('Tempo (segundos)')
ax1.set_ylabel('Requisições por Segundo (RPS)', color=color)
ax1.plot(df_agg['Time_Sec'], df_agg['Requests/s'], color=color, label='RPS')
ax1.tick_params(axis='y', labelcolor=color)
ax1.grid(True, which='both', linestyle='--', linewidth=0.5)

ax2 = ax1.twinx()  
color = 'tab:gray'
ax2.set_ylabel('Usuários Simultâneos', color=color)  
ax2.plot(df_agg['Time_Sec'], df_agg['User Count'], color=color, linestyle='--', label='Usuários')
ax2.tick_params(axis='y', labelcolor=color)

plt.title('Performance: RPS vs Usuários (Cenário 150 Users)')
fig.tight_layout()  
plt.savefig('grafico_rps.png')
print("Gráfico RPS salvo como grafico_rps.png")

# --- GRÁFICO 2: LATÊNCIA ---
plt.figure(figsize=(10, 6))
plt.plot(df_agg['Time_Sec'], df_agg['Total Median Response Time'], label='Mediana (50%)', color='green')
plt.plot(df_agg['Time_Sec'], df_agg['95%'], label='P95 (95%)', color='red', linewidth=2)

# Linha do Limite (SLA)
plt.axhline(y=10000, color='black', linestyle='--', label='Limite SLA (10s)')

plt.xlabel('Tempo (segundos)')
plt.ylabel('Tempo de Resposta (ms)')
plt.title('Latência vs Tempo (Cenário 150 Users)')
plt.legend()
plt.grid(True)
plt.savefig('grafico_latencia.png')
print("Gráfico Latência salvo como grafico_latencia.png")