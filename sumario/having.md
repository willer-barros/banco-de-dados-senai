## Having


O HAVING no Postgres funciona como um filtro especial de grupo, como se fosse um inspetor que só deixa passar as equipes que batem uma meta específica depois que todo mundo já se juntou.
Para entender fácil, imagine uma fábrica de caixas de brinquedos:
GROUP BY (Separar em caixas):
Primeiro, você pega uma montanha de brinquedos misturados e organiza em caixas. Uma caixa só de carrinhos, uma só de bonecas e uma só de bolas.
WHERE (Filtro antes da caixa): Se você quisesse jogar fora os brinquedos quebrados antes de colocá-los nas caixas, você usaria o WHERE.
HAVING (Filtro depois da caixa pronta): Depois que as caixas estão cheias, o chefe da fábrica diz: "Só vamos enviar as caixas que tiverem mais de 10 brinquedos dentro!".
O HAVING é exatamente esse teste final. Ele não olha para um brinquedo sozinho; ele olha para a caixa fechada e conta o total dela. Se a caixa de carrinhos tiver 12, ela passa. Se a de bonecas tiver só 5, o HAVING joga a caixa inteira fora!
A diferença que não dá para esquecer:
WHERE chuta os brinquedos ruins antes deles entrarem nas caixas.
HAVING chuta as caixas inteiras depois que os brinquedos já foram guardados e contados.
