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
