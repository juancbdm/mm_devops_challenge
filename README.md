
# Resolução 
Dado o enunciado, foi criado um arquivo em yaml para ser consumido pelo docker-composer, com o proxy reverso configurado corretamente seguindo a documentação da imagem referenciada, inserindo o arquivo ```nginx-proxy.local``` com os redirecionamentos necessários para a pasta ```/etc/nginx/vhost.d``` no containter responsável. Necessário também a inserção de variáveis de ambiente nos containers responsáveis pela aplicação para o funcionamento correto e expondo a porta a ser usada. E por fim tudo conectado em um rede criada para os containers.

**— Extra**
Criei uma implementação opcional com os certificados e um script para não interferir no que foi pedido no enunciado.

A aplicação por padrão esta rodando na porta 8080, se optar pela instalação com SSL a aplicação responderá na porta 443 (padrão do https) e seu browser pedira para proceder de forma insegura, pois é um certificado "self-signed".

Se feito pelo script ```startup.sh``` você terá 3 opções, fora a opção ```destroy```, é iniciado uma instância do seu navegador padrão(se estiver usando alguma distribuição linux com xdg ou gnome):
* ```./startup.sh``` — Sem nenhum parâmetro, ele subira o docker-compose com as configurações padrão, pedidas no enunciado.
* ```./startup.sh destroy``` — Remove os containers ativos e certificados na pasta ```configs/certs``` e comenta o codigo para SSL no yaml.
* ```./startup.sh ssl``` — Gera os certificados(necessário openssl), remove comentários no yaml adiciona ```127.0.0.1 nginx-proxy.local``` ao seu arquivo hosts e sobe os containers.


## Possiveis testes:
**Default**:
* ```curl http://localhost:8080/app1```
* ```curl http://localhost:8080/app2```

**SSL**:
* ```https://nginx-proxy.local/app1```
* ```curl -kL -H "Host: nginx-proxy.local" localhost:8080/app1``` (redirect insecure connection)
* ```curl -k https://nginx-proxy.local/app1```

## Referencias
[Create an SSL certificate](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04#step-1-create-the-ssl-certificate)
