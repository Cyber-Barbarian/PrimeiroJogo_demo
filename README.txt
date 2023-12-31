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
	vamos criar uma nova cena para o inimigo, asim como fizemos com o personagem
	CharachterBody2d + Sprite2d + ColisionShape2D + AnimationPlayer + Area2D(área de detecção) + ColisionShape2D + AnimationPlayer auxiliar
	Carregamos todas as animações, mesmo padrão do herói
	ajustamos a colisão na sombra e movemos para cima de texture, assim é renderizado atrás
	em DetectionArea/Colision criamos uma área de colisão circular partindo do pé do personagem de raio 250 px e passamos a detection area para cima tb

Associando código
	criamos variaveis de velocidade e player_ref, e em detection area associamos a colisão à mascara 1 e sem layer
	ja no goblin (CharacterBody2d/Collision), colocamos ele no layer 2, mascara 1
	Vamos conectar dois sinais da DetectioArea:  body_entered e body_exited e colocamos para printar body
	Vamos criar a cena do nível para ve a interação. 2DScene, renomeada para Level e salvar
	Em Level/Scene vamos linkar os objetos Goblin e Knight no símbolo de corrente
	rodando nosso lavel vamos ver que ele printa o cavaleiro ao entrar e sair da área
	vamos trabalhar o movimento do goblin pela detecção do cavaleiro (player_ref) e pelo vetor de direção (var direction: Vector2 = global_position.direction_to(player_ref.global_position))
	com a palavra reservada velocity e o método move_and_slide() vamos fazer nosso inimigo se mover

Integrando animações
	primeiramente armazenaremos a distância do nosso inimigo e o cavaleiro
	com base na distância vamos renderizar o ataque
	criaremos a função animate 
	vamos copiar o update health do nosso personagem para nosso inimigo
	vamos conectar o animation finished no goblin
	Em level, selecionando cada um dos characterBody2d (goblin e guerreiro) e indo no inspector temos que desativar em Moving Plataform os Floor layers 1 e 2 e ativar como wall layers ou goblin e guerreiro podem se interpretar como plataformas e podem ficar "grudados" 
	
Criando area de ataque e flip do inimigo
	#inroduzimos o flip no codigo
	pra area de ataque do inimigo vamos fazer algo diferente. vamos criar uma cena que vai ser a área de ataque, que será deletada em alguns segundos (uma área 2d)
	EnemyAttackArea2D -> criamos um ColisionShape2D circular com um raio de 80px, retiramos odas as layers e deixamos a mask em 1  e criamos para ela um script
	no script vamos conectar o sinal de on_body_entered e criar um damage para que nosso personagem tome dano
	olhando o animation do nosso goblin vemos que o dano ocorre entre os frames 0.3 e 0.4
	dessa forma vamos introduzir no nosso EnemyAttackArea2D um timer, marcando oneshot e autostart
	nossa área de ataque terá, como vimos em animation, tem um spawn de apenas 0.1s, então tb mudamos o wait time para 0.1s
	vamos conectar no código um sinal de timeout para deletarmos o temporizador após a execução (renomeei para _on_lifetime_timeout e adicionei o queue_free)
	agora sincronizaremos a animação do goblin com o método do código de enemyAttackArea2D
	No código do goblin criamos uma função que spawna a área de ataque (spawn_attack_area)
	criamos uma const ENEMY_ATTACK_AREA que será uma cena (PackedScene) e pre carregamos (preload) nossa cena EnemyAttackArea2D
	com o preload podemos pré carregar uma cena, sem a necessidade de acrescentá-la manualmente como filha em goblin
	em spawn_attack_area instanciamos nossa área de ataque, determinamos a posição e adicionamos ela via código como filha 
	queremos que a spawn_attack_area seja chamada somente no frame exato de ataque
	para isso vamos em Goblin/Animation, mudamos para o frame de ataque, clicamos em Add Track e escolhemos Call Method Track,selecionamos goblin e clicamos em ok
	agora podemos inserir qalquer método do código, em qualquer momento
	em 0.3 clicamos com o direito e vamos inserir a key spawn_attack_area. rodando o level com f6 vemos que há descompasso entre área de colisão e personagem.
	obtivemos um bug da área. olhar o comentário entre aspas em spawn_attack_area
	ajustamos o comportamento do goblin para parar de atacar quando morremos

Terreno
	criaremos em level um node2D chamado terrain e adicionaremos como filho dele um tilemap e chamaremos de grass
	no inspector vamos mudar o tamanho do quadrante para 64 e criar o tile  set, especificando um tile size de 64X64 px
	em files, vamos pegar nossa grama (terrain/ground/grass.png) e arrastar para tiles, criando o atlas
	temos agora as texturas bases
	mas primeiro, no inspector, vamos em terrain sets e adicionaremos um elemento para criar um autotile, a propria godot calcula o melhor tile
	vamos na parte inferior em paint, selecionamos a propriedade terrains
	Vamos pasar o terrains set 0 em em no terrain o terrain 0 que criamos, e vamos marcando do lado os blocos que desejamos
	selecionamos tudo menos a borda
	agora vamos na parte inferior em tileMap, terrains, selecionamos terrain 0
	fui antes no goblin e no knight e desmarquei canvas item visibility para ver melhor
	com o clique esquerdo vamos pintando, com o direito apagando, ctrl+shift ajudam a fazer em área
	ponto importante: terrain tem que ser passado para o topo para ser renderizado por último, se não fica em cima dos bonecos
	voltando para knight, vamos adicionar uma câmera em nosso personagem, não fizemos antes pq seria complicado debugar sem o terreno
	em knight vamos adicionar uma camera 2d (camera). ela por padrão já vem ativada
	em inspector vamos marcar position smooting pra suavizer o movimento
	vamos adicionar um novo tilemap que chamaremos de water, e terá a água e colisão do limite do terreno(mesmo esquema, 64X64 px)
	adicionamos a agua (tileset/tiles/adicionamos a water.png)
	no nó Water vamos em phisics layers e adicionamos elemento, criando uma camada de colisão,
	colocamos mascara na camada 1 e 2. desmarcamos o colision layer
	em tileset/tiles/paint vamos na propriedade physics layer 
	damos um click em base tiles para adicionar a colisão.

Água via código
	vamos adicionar a água via código no terreno
	após adicionar, vimos que a água fico acima da grama. invertemos a posição dos nós.
	BUG -> nosso personagem se move na água. 
	vamos ajustar a colisão em level/goblin e level/knight acrescentando mascara na camada 3.
	ainda em level, em seguida vamos adicionar  colision layer 3 em water
	O bug aconteceu pq as células de água foram adicionadas no mesmo spot que as de grama. vamos então melhorar nossa função no código
	isso é resolvido pela variável grass_used_cells e um condicional

spawnando a maré na borda
	vamos criar uma nova cena com animatedSprite2D (Foam)
	no inspector vamos em animatedSprite2d, Animation, sprite. criamos um novo
	na parte inferior em SpriteFrames renomeamos a animação para idle e colocamos com 10FPS
	ainda na parte inferior, no grid, vamos procurar nosso foam.png e adicionar, alterando para 8 grids na horizontal e 1 na vertical
	dando play podemos ver como fica. salvamos e fechamos
	voltamos em level e vamos adicionar via código no terreno
	BUG -> a maré está renderizando no topo do terreno solução:
		na cena foam, vamos em  foam/ordering/z index vamos diminuiro o index para -1
		ainda em foam vamos em SpriteFrames e marcamos o A de autoplay on load
		na cena level,  water/ordering vamos diminuir para -2

Criando menu
	usaremos a fonte kurland
	criaremos uma nova cena do tipo User interface, renomeamos para menu e adicionamos uma label (game name)
	Alinhamos à esquerda com centro e adicionamos a fonte kurland. aumentamos a fonte para 64px, adicionamos margem em layout etc...
	adicionaremos  caixas de seleção VBoxContainer e renomeamos para ButtonsContainer
	setamos o tamanho 240X300, alinamos bottom right e colocamos um offset de -60 em ambas as direçoes
	dentro dela adicionaremos os bottoes (button), colocamos new game com nossa fonte. duplicamos para criar o botão de quit e em buttonContainer criamos uma separação
	adicionamos ambos os botoes no grupo botão
	vamos associar um script e para cada botão dar uma função, conectando o sinal de pressionado
	
Criando transição
	nova cena -> canvas layer (transition screen) com um color rect de tela toda (anchor full rect) na cor preta
	vamos adicionar um no de animação e criar uma animação fade in e outra fade out
	adicionamos a função de fade in e fade out via script
	para podermos utilizar nossa cena de fade in e fade out de qualquer lugar do projeto, vamos pre carrega-la. na parte superior vamos em Project>Project Sttings>Autoload e caregamos a cena de transition screen
	agora ela é acessável de toda parde do nosso projeto, podendo ser acessada de nosso menu
	alteramos tb o filtro do mouse de nossa transition screen para ignore
	fizemos tb um fade out ao abrir o jogo e um fade in ao dar quit (variavel can_quit)
	na cena level, em terrain, clicamos com o direito e salvamos a branch terrain como uma cena. em seguida clicamos tb com o direito e marcamos make local
	em menu vamos instanciar (simbolo da corrente) o terreno que salvamos, tornal local e vamos apagar um pouco de grama. apagamos todo e desenhamos um pouquinho de grama. diminuímos o z index para aparecer no fundo
	vamos rodar o menu novamente, mas dessa vez com F5, e tornar a cena do menu nossa cena principal. isso tb pode ser feito em propriedades. (project > project settings > application > run)
