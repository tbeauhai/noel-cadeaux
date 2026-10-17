# Mes cadeaux de Noël

Un petit site pour suivre les idées de cadeaux, les achats et le budget pour chaque proche.
La liste est enregistrée dans une base Supabase commune, avec mise à jour en direct.
Seules les adresses e-mail que vous autorisez peuvent se connecter et voir la liste.

Sans configuration, le site fonctionne en mode local (données gardées dans le navigateur, sans connexion).

## Fichiers

- `index.html` : le site complet (HTML, CSS, JavaScript)
- `config.js` : l’adresse et la clé publique de votre projet Supabase
- `schema.sql` : les tables et les règles d’accès à exécuter dans Supabase

## 1. Créer la base de données (Supabase, gratuit)

1. Créez un compte sur https://supabase.com puis un nouveau projet.
2. Ouvrez `schema.sql`, remplacez `vous@exemple.fr` par votre adresse (et ajoutez celles des
   personnes qui partagent la liste), puis collez le tout dans **SQL Editor > New query** et cliquez sur **Run**.
3. Dans **Project Settings > API**, copiez la **Project URL** et la clé **anon public**,
   puis collez-les dans `config.js`.

## 2. Configurer la connexion par e-mail

Dans **Authentication > URL Configuration** :

- **Site URL** : l’adresse de votre site, par exemple `https://VOTRE-COMPTE.github.io/noel-cadeaux/`
- **Redirect URLs** : ajoutez cette même adresse, ainsi que `http://localhost:8000/` pour vos tests.

Sans cela, le lien reçu par e-mail renverra vers une mauvaise adresse.

Le lien de connexion doit être ouvert sur le même appareil et dans le même navigateur que
celui où la connexion a été demandée.

## 3. Gérer les personnes autorisées

Pour ajouter quelqu’un, dans **SQL Editor** :

```sql
insert into public.allowed_emails (email) values ('prenom@exemple.fr');
```

Pour retirer quelqu’un :

```sql
delete from public.allowed_emails where email = 'prenom@exemple.fr';
```

Vous pouvez aussi passer par **Table Editor > allowed_emails**. Écrivez les adresses en minuscules.

Une personne non autorisée peut demander un lien et se connecter, mais elle voit seulement
« Accès non autorisé » : la base refuse de lui montrer ou de modifier quoi que ce soit.
Pour empêcher aussi la création de comptes, désactivez **Allow new users to sign up**
dans **Authentication > Sign In / Providers** après la première connexion de chaque personne autorisée.

## 4. Tester en local

Le lien de connexion ne fonctionne pas en ouvrant directement le fichier : lancez un petit serveur.

```bash
python3 -m http.server 8000
# puis ouvrez http://localhost:8000
```

## 5. Publier avec GitHub Pages

```bash
git init
git add .
git commit -m "Mes cadeaux de Noël"
git branch -M main
git remote add origin https://github.com/VOTRE-COMPTE/noel-cadeaux.git
git push -u origin main
```

Puis sur GitHub : **Settings > Pages > Build and deployment**, source **Deploy from a branch**,
branche `main`, dossier `/ (root)`.

## Bon à savoir

- La clé « anon » visible dans `config.js` est faite pour être publique : ce sont les règles
  de `schema.sql` qui protègent les données.
- Le service d’e-mail intégré à Supabase est limité à quelques e-mails par heure pour tout
  le projet, et ses modèles d’e-mail ne sont pas modifiables sur l’offre gratuite.
  Pour lever ces limites, configurez votre propre SMTP (par exemple Brevo, avec un nom de
  domaine vérifié) dans **Authentication > Emails > SMTP Settings**.
