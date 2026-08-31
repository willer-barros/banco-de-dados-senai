import pkg from 'pg'
const { Pool } = pkg;

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'db-teste',
    password: 'senai',
    port: 5433,
})

function gerarNomeAleatorio() {
    const primeiroNomes = ['Ana', 'Bruno', 'Carlos', 'Daniela', 'Eduardo', 'Fernanda', 'Gabriel', 'Helena', 'Igor', 'Juliana', 'Lucas', 'Mariana', 'Nicolas', 'Patrícia', 'Rafael', 'Sofia', 'Thiago', 'Vanessa'];
    const sobrenomes = ['Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes', 'Costa', 'Ribeiro', 'Martins', 'Carvalho', 'Almeida', 'Lopes'];

    const p = primeiroNomes[Math.floor(Math.random() * primeiroNomes.length)]
    const s = sobrenomes[Math.floor(Math.random() * sobrenomes.length)]

    const s2 = sobrenomes[Math.floor(Math.random() * sobrenomes.length)]

    return `${p} ${s} ${s2}`
}

function gerarCpfAleatorio() {
    const n = () => Math.floor(Math.random() * 9)
    const n1 = n(), n2 = n(), n3 = n(), n4 = n(), n5 = n(), n6 = n(), n7 = n(), n8 = n(), n9 = n();
    const d1 = Math.floor(Math.random() * 9);
    const d2 = Math.floor(Math.random() * 9);
    console.log(`${n1}${n2}${n3}${n4}${n5}${n6}${n7}${n8}${n9}${d1}`)
    return `${n1}${n2}${n3}${n4}${n5}${n6}${n7}${n8}${n9}${d1}`;
}   

async function popularBanco() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    

    const totalRegistros = 100000;
    const tamanhoLote = 500;
    console.log(`Iniciando a criação de ${totalRegistros} registros...`);

    for (let i = 0; i < totalRegistros; i += tamanhoLote) {
      let valoresQuery = [];
      let placeholders = [];
      let contadorParametro = 1;

      for (let j = 0; j < tamanhoLote && (i + j) < totalRegistros; j++) {
        const nome = gerarNomeAleatorio();
        const cpf = `${gerarCpfAleatorio()}-${i+j}`; 

        placeholders.push(`($${contadorParametro}, $${contadorParametro + 1})`);
        valoresQuery.push(nome, cpf);
        contadorParametro += 2;
      }

      const queryLote = `INSERT INTO pessoa (nome, cpf) VALUES ${placeholders.join(', ')};`;
      await client.query(queryLote, valoresQuery);
      
      const progresso = i + tamanhoLote > totalRegistros ? totalRegistros : i + tamanhoLote;
      console.log(`Inseridos ${progresso} de ${totalRegistros} registros...`);
    }

    await client.query('COMMIT'); // Confirma as alterações
    console.log('Povoamento concluído com sucesso!');
  } catch (error) {
    await client.query('ROLLBACK'); // Desfaz tudo em caso de qualquer falha
    console.error('Erro ao popular o banco de dados:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

popularBanco();