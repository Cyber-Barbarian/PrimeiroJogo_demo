Esse é um projeto de uso pessoal, somente para estudo.
Estou utilizando este documento para estruturar um passo a passo da criação do jogo demo. 

Asset base: Tiny swords versão demo
 
Estrutura inicial do personagem:
	Criamos um nó do tipo CharacterBody2D(Knight).
	Acrescentamos um nó de Sprite de sua textura (Texture) e um shape de colisão (nó ColisionShape2D/Colision) como filhos
	Em seguida, em textura, basta arrastarmos a cena do guerreiro (warrior.png) para nosso nó
	Dentro do nó de Sprite 2D, no Inspector, em animation, setamos os frames: 6 Hframes e 3 Vframes pois é o quanto de frames temos no nosso guerreiro
	Para ir animando basta ir mudando os Frames
	Por fim vamos definir a colisão. Em colision, vamos definir uma colisão retangular pegando somente os pés e a sombra do personagem, e subir o nó de colisão uma posição acima para que seja renderizado atrás do personagem.
	Salvamos tudo em src/knight
	
Criando código de movimentação top/down
	Direção
		Criaremos um código knight.gd na mesma pasta do nosso personagem (criar codigo vazio)
		Vamos começar tratando a física, criano a função _physics_process
		Estabelecemos a movimentaçã pela função get_direction, que gera um vetor 2d, representando a posição x/y
		Para pegar a direção de movimentação usamos Input.get_axis() onde são passados os argumentos de direção negativa (esquerda/cima) e positiva (direita/baixo)
		Para consultar os inputs possiveis na godot basta ir em Project>Project Settings> Input Map e flagar os built in actions
		Já conseguimos printar nosso input de setas (print(direction))
		Se observarmos, por conta da geometria vetorial o nosso personagem andará nas diagonais mais rápido que nas demais direções (print(direction.length()) na diagoal é maior). Então normalizamos o vetor (normalized())
	Velocidade
		Definiremos agora a velocidade por meio de uma variável do tipo export (@export move_speed)
		podemos agora aplicar a velocidade por meio da palavra reservada velocity, que é um vetor 2d
		em seguida aplicamos o método nativo de CharacterBody2d move_and_slide, que executa a movimentação baseado na velocity e ativa colisões
		Já conseguimos movimentar nas 8 direções
		Vamos alterar a textura de nosso personagem , novamente em Project> Project Settings > Rendering > Textures mudamos de Linear para nearest, para trar o efeio blur e ficar mais pixelizado. Vai funcionar para todas as texturas do projeto
		Adicionei WASD como padrão de movimentação, adicionando elas manualmente no Project>Project Settings> Input Map

Criando as animações do personagem
	Vamos adicionar um nó Animation Player na cena e renomear para Animation
	No nó Animation, clicando em Animation > New vamos criar a animação idle, representando o personagem parado
	Se olharmos agora para o inspector de Colision e Texture ou do próprio Knight  vamos ver que há agora o símbolo de chave
	São keys de animação para textura, personagem ou qualquer outra coisa que quisermos
	Vamos em nosso nó Texture, no Inspector marcamos a key em Texture para criar uma track de textura em nossa linha do tempo
	Ainda no inspector, em animation vamos marcar a key Hframes, Vframes e Frame
	Vamos clicando na key de frame somente até o nosso personagema tingir o primeiro frame de corrida. a engine vai mostrando o próximo frame
	Com control + roda do mouse, damos zoom nossa animação na parte inferior, aumentamos o tempo para 0.6, marcamos loop e damos play
	Da mesma forma criamos as animações de corrida e ataque.
	Obs a animação attack foi feita com o método duplicate.
	
Integrando as animações por código
	Criamos uma variável de referência ao animation player
	separamos o movimento na função move e criamos a função animate
	criamos a função attack_handler e a variável can_attack para lidar com a ação específca de ataque dentro da função animate
	criamos um bloco verificando se can_attack é flase para tratar o problema de atacar enquanto se move
	devemos prestar atenção no botão de loop das aimações. a unica que NÃO deve ter ele marcado é a de attack
	um ponto de destaque é que, ao fim da animação, nosso boneco trava. isso acontece pq o can_attack fica setado para false e n]ão volta para true. 
	para resolver isso conectamos o sinal de animação "animation_finished" disponível na aba node do inspector de animação (func _on_animation_finished)
	usamos flip_h baseadom na velocity.x para girar o eixo do personagem.

Hitbox de ataque
	mudamos para o frame específico do ataque (0.3) e inserimos um nó do tipo area2d, que monitora ações de colisão
	renomeamos para AttackArea e inserimos uma área de colisão (ColisionShape2D/Colision)
	inserimos uma colision shape retangular, pegando toda a ára da espada. Essa é nossa hitbox de ataque
	Vamos agora tratar via código a área de ataque para que ela mude junto com o flip_h (attack_area_colision.position.x). 
	Em debug marcamos Visible colision shapes e rodamos. Desabilitamos a colisão no inspector para sincronizar ela com o frame de ataque 
	Fazemos isso inserindo keys de disabled na animação (AttackArea/Collision/Inspector/Disabled)
	Fazemos isso na animação de attack e animação de reset  rodamos as animações
	agora vamos conectar um sinal do tipo body_entered (AttackArea/Node/body_entered) ao nosso personagem
	manipulamos a Layer e Mask de nossa AttackArea para evitar que o personagem de hit em si  mesmo (AttackArea/Inspector/CollisionObject2D/Collision)
	layer é aquilo que se é no mundo. a mask é aquilo que vc interage. nosso personagem é então da layer 1, com mask 2. Assim ele não colide com nada da layer 1, só 2
	essa prática é importantepara evitar que o personagem de hit em si mesmo em caso de overlap
	criamos uma função de update health e vamos forçar o overlap para teste, colocando o personagem na layer 2 e alterando attack_area_colision.position.x
	voltamos aos valores originais
hit e morte
	em animation vamos criar a animação death e etar para cerca de 2 segundos
	em texture importamos a animação de morte para o 2d do personagem, lembrando de adicionar as keys de texture, hframes, v frames e frames, assim não haverá bug com as demais texturas
	vamos tratar a morte de nosso personagem pela variável can_die , que vai auxiliar a determinar que animações devem ser renderizadas
	desabilitamos a area de colisão para o caso de morte
	vamos agora tratar da animação de hit por meio de uma animation auxiliar
	na animação de hit vamos alterar somente o modulate da textura, fazendo o boneco ficar vermelho
	Texture>inspector>canvasItem>modulate : no instante 0.0 botamos um key modulate para vermelho e na sequencia em 0.2 um key modulate para branco
	inserimos em código, da mesma forma que o animate dentro da update_health
	retornamos a hitbox (attack_area_colision.position.x) ao tamanho normal (56)
	Na AttackArea vmos deixar o personagem somene na layer 1, com mask 2
	desmarcamos o visible colision shapes do debug e nosso personagem já está funcional

Estrutura dos inimigos 
