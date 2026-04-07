from database import carregar_estoque

def calcular_resumo_estoque():
    dados = carregar_estoque()

    faturamento_total = 0
    custo_total = 0
    lucro_total = 0
    quantidade_total = 0

    for item in dados:
        quantity = item["quantity"]
        buyPrice = item["buyPrice"]
        preco_custo = item["preco_custo"]

        faturamento_total += valor_venda * quantidade
        custo_total += preco_custo * quantidade
        lucro_total += (valor_venda - preco_custo) * quantidade
        quantidade_total += quantidade


    print(f"Quantidade total de itens: {quantidade_total}")
    print(f"Faturamento potencial: R$ {faturamento_total:.2f}")
    print(f"Custo total do estoque: R$ {custo_total:.2f}")
    print(f"Lucro potencial: R$ {lucro_total:.2f}")

calcular_resumo_estoque()