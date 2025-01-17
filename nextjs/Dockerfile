# Build app
FROM node:alpine3.20 AS build

WORKDIR /app

COPY package*.json .

RUN npm install 

COPY . .

WORKDIR /app

RUN npm run build

#  Run app from build
FROM node:alpine3.20

RUN apk add --no-cache libc6-compat && npm install -g sharp
# Copy build
COPY --from=build /app/.next ./.next
COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/public ./public


EXPOSE 3000

CMD [ "npm", "run", "start" ]

