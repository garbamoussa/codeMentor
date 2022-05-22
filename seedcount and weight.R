meanweight<-weight%>%
  group_by(id)%>%
  mutate(mean =mean(Mass))
meanweight <-weight%>%
  group_by(id)%>%
  summarise(mean=mean(Mass))

meanweight%>%
  group_by(id)

countandweight<-merge(mean,count, by="id")

model<-lm(mean_by_id~SeedCount, data=countandweight)
summary(model)
plot(model)

plot(mean_by_id~SeedCount, data=countandweight)

x<-countandweight$SeedCount
y<-countandweight$mean_by_id
plot(x,y, main = "Average Seed Weight and Seed Count Per Head",
        xlab = "Seed Count", ylab= "Average Seed Weight", 
        pch=19, frame= FALSE)
abline(lm(y~x,data = countandweight), col= "blue")






