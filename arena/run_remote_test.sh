#!/bin/bash
# run_remote_test.sh
# Uso: bash run_remote_test.sh <DNS_LB> <USUARIOS> [DURACAO]

# --- CONFIGURAÇÃO ---
KEY_FILE="chave-aluno.pem" 
# --------------------

if [ -z "$1" ] || [ -z "$2" ]; then 
    echo "Uso: bash run_remote_test.sh <DNS_LB> <USUARIOS> [DURACAO]"
    exit 1
fi

TARGET_DNS="$1"
if [[ $TARGET_DNS != http* ]]; then TARGET_DNS="http://$TARGET_DNS"; fi
USERS=$2
DURATION=${3:-7m} 

if [ ! -f ".generator_ip" ]; then echo "Erro: .generator_ip não encontrado."; exit 1; fi
GEN_IP=$(cat .generator_ip)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_DIR="resultados_${USERS}users_${DURATION}_${TIMESTAMP}"

echo ">>> TESTANDO: $USERS usuários por $DURATION em $GEN_IP"
ssh -i $KEY_FILE -o StrictHostKeyChecking=no ec2-user@$GEN_IP "./wrapper.sh $TARGET_DNS $USERS $DURATION"

echo ">>> BAIXANDO RESULTADOS..."
mkdir -p $RESULT_DIR
scp -i $KEY_FILE -o StrictHostKeyChecking=no ec2-user@$GEN_IP:/home/ec2-user/dados_*.csv ./$RESULT_DIR/
echo ">>> SUCESSO. Resultados em ./$RESULT_DIR/"